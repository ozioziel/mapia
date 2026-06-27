import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapiafrontend/core/config/app_config.dart';
import 'package:mapiafrontend/core/platform/google_maps_web_loader.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/map/services/places_api.dart';
import 'package:mapiafrontend/features/map/utils/bolivia_bounds.dart';

class EventLocationSelection {
  const EventLocationSelection({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.address,
  });

  final double latitude;
  final double longitude;
  final int radiusMeters;
  final String? address;
}

/// Selector de ubicación para Crear Evento: buscador (Places), mapa interactivo
/// (gestos propios, no mueve la pantalla), marcador, círculo de radio y slider.
class EventLocationPicker extends StatefulWidget {
  const EventLocationPicker({
    super.key,
    required this.onChanged,
    this.initial,
  });

  final EventLocationSelection? initial;
  final ValueChanged<EventLocationSelection> onChanged;

  @override
  State<EventLocationPicker> createState() => _EventLocationPickerState();
}

class _EventLocationPickerState extends State<EventLocationPicker> {
  final PlacesApi _places = PlacesApi();
  final TextEditingController _searchController = TextEditingController();

  GoogleMapController? _mapController;
  LatLng? _selected;
  String? _address;
  int _radius = 0;

  List<PlaceSuggestion> _suggestions = const [];
  Timer? _debounce;
  bool _isMapSdkLoading = kIsWeb && AppConfig.googleMapsApiKey.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _radius = widget.initial?.radiusMeters ?? 0;
    _address = widget.initial?.address;
    if (widget.initial != null) {
      _selected = LatLng(widget.initial!.latitude, widget.initial!.longitude);
    }
    _loadSdk();
    if (_selected == null) {
      _useCurrentLocation(emit: true);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSdk() async {
    if (!kIsWeb || AppConfig.googleMapsApiKey.isEmpty) return;
    try {
      await ensureGoogleMapsWebLoaded();
    } catch (_) {
      // si falla, el mapa mostrará el estado de error nativo
    } finally {
      if (mounted) setState(() => _isMapSdkLoading = false);
    }
  }

  void _emit() {
    final point = _selected;
    if (point == null) return;
    widget.onChanged(
      EventLocationSelection(
        latitude: point.latitude,
        longitude: point.longitude,
        radiusMeters: _radius,
        address: _address,
      ),
    );
  }

  Future<void> _setSelected(LatLng point, {bool reverse = true}) async {
    setState(() => _selected = point);
    _emit();
    await _mapController?.animateCamera(CameraUpdate.newLatLng(point));
    if (reverse) {
      try {
        final address = await _places.reverseGeocode(
          point.latitude,
          point.longitude,
        );
        if (!mounted) return;
        if (address.isNotEmpty) {
          setState(() => _address = address);
          _emit();
        }
      } catch (_) {}
    }
  }

  Future<void> _useCurrentLocation({bool emit = false}) async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos =
          await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition();
      if (!mounted) return;
      await _setSelected(LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      if (emit) return;
    }
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    if (text.trim().length < 2) {
      setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final results = await _places.autocomplete(
          text,
          lat: _selected?.latitude,
          lng: _selected?.longitude,
        );
        if (!mounted) return;
        setState(() => _suggestions = results);
      } catch (_) {
        if (mounted) setState(() => _suggestions = const []);
      }
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _suggestions = const [];
      _searchController.text = suggestion.description;
    });
    try {
      final details = await _places.details(suggestion.placeId);
      if (!mounted) return;
      _address = details.address.isNotEmpty ? details.address : suggestion.description;
      await _setSelected(LatLng(details.lat, details.lng), reverse: false);
    } catch (_) {}
  }

  void _setRadius(double value) {
    setState(() => _radius = value.round());
    _emit();
  }

  String get _radiusLabel {
    if (_radius <= 0) return 'Sin radio (punto exacto)';
    if (_radius < 1000) return '$_radius m';
    return '${(_radius / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMapBox(),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.radio_button_checked, size: 18, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Text(
              'Radio del evento: $_radiusLabel',
              style: const TextStyle(
                color: AppTheme.textNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Slider(
          value: _radius.toDouble().clamp(0, 5000),
          min: 0,
          max: 5000,
          divisions: 50,
          label: _radiusLabel,
          onChanged: _setRadius,
        ),
        if (_address != null && _address!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                const Icon(Icons.place_rounded, size: 16, color: AppTheme.mutedText),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _address!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.mutedText,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMapBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(child: _buildMap()),
            Positioned(
              left: 10,
              right: 10,
              top: 10,
              child: _buildSearch(),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: FloatingActionButton.small(
                heroTag: 'event_loc_my_location',
                onPressed: () => _useCurrentLocation(),
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlue,
                child: const Icon(Icons.my_location_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (kIsWeb && AppConfig.googleMapsApiKey.isEmpty) {
      return const ColoredBox(
        color: Color(0xFFEFF3F0),
        child: Center(
          child: Text('Configura GOOGLE_MAPS_API_KEY para el mapa'),
        ),
      );
    }
    if (_isMapSdkLoading) {
      return const ColoredBox(
        color: Color(0xFFEFF3F0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final center = _selected ?? boliviaCenter;
    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: _selected == null ? 5.4 : 15,
      ),
      onTap: (point) => _setSelected(point),
      markers: {
        if (_selected != null)
          Marker(
            markerId: const MarkerId('event_location'),
            position: _selected!,
            draggable: true,
            onDragEnd: (point) => _setSelected(point),
          ),
      },
      circles: {
        if (_selected != null && _radius > 0)
          Circle(
            circleId: const CircleId('event_radius'),
            center: _selected!,
            radius: _radius.toDouble(),
            strokeWidth: 2,
            strokeColor: AppTheme.primaryBlue,
            fillColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
          ),
      },
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      // Clave: el mapa consume sus gestos => no mueve el scroll de la pantalla.
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
    );
  }

  Widget _buildSearch() {
    return Column(
      children: [
        Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(12),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              hintText: 'Buscar ubicación del evento...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _suggestions = const []);
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.liftedShadow,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final s = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.place_outlined, size: 20),
                  title: Text(
                    s.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  onTap: () => _selectSuggestion(s),
                );
              },
            ),
          ),
      ],
    );
  }
}
