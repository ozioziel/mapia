import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapiafrontend/core/config/app_config.dart';
import 'package:mapiafrontend/core/platform/google_maps_web_loader.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/map/presentation/widgets/map_post_preview_card.dart';
import 'package:mapiafrontend/features/map/services/map_api.dart';
import 'package:mapiafrontend/features/map/services/reports_api.dart';
import 'package:mapiafrontend/features/map/styles/mapia_map_style.dart';
import 'package:mapiafrontend/features/map/types/alert_map_types.dart';
import 'package:mapiafrontend/features/map/types/post_map_marker_types.dart';
import 'package:mapiafrontend/features/map/utils/bolivia_bounds.dart';
import 'package:mapiafrontend/features/map/utils/severity.dart';
import 'package:mapiafrontend/features/posts/data/datasources/mock_posts_datasource.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';
import 'package:mapiafrontend/shared/widgets/mapia_bottom_navigation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapApi = MapApi();
  final _reportsApi = ReportsApi();
  final List<PostEntity> _explorePosts = const MockPostsDatasource().getPosts();

  GoogleMapController? _mapController;
  AlertFilters _filters = const AlertFilters();
  AlertFilterOptions _filterOptions = const AlertFilterOptions();
  List<AlertMapItem> _alerts = [];
  AlertMapItem? _selected;
  PostEntity? _selectedExplorePost;
  PostMapMarkerIcons? _postMarkerIcons;
  Set<PostType> _enabledPostTypes = PostType.values.toSet();
  bool _isLoading = true;
  bool _isLocating = true;
  bool _isMapSdkLoading = kIsWeb && AppConfig.googleMapsApiKey.isNotEmpty;
  bool _hasLocationPermission = false;
  bool _filtersOpen = false;
  String? _error;
  LatLng? _currentLocation;
  static const double _nearbyRadiusKm = 3;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    _loadPostMarkerIcons();
    await _loadGoogleMapsSdk();
    await _requestCurrentLocation();
    await _loadAlerts();
  }

  Future<void> _loadPostMarkerIcons() async {
    final icons = await PostMapMarkerIcons.create();
    if (!mounted) return;
    setState(() => _postMarkerIcons = icons);
  }

  Future<void> _loadGoogleMapsSdk() async {
    if (!kIsWeb || AppConfig.googleMapsApiKey.isEmpty) return;
    try {
      await ensureGoogleMapsWebLoaded();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isMapSdkLoading = false);
      }
    }
  }

  Future<void> _requestCurrentLocation({bool moveCamera = false}) async {
    setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _isLocating = false;
          _hasLocationPermission = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final allowed =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!allowed) {
        if (!mounted) return;
        setState(() {
          _isLocating = false;
          _hasLocationPermission = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() {
        _currentLocation = location;
        _hasLocationPermission = true;
        _isLocating = false;
      });

      if (moveCamera) {
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(location, 14),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLocating = false);
    }
  }

  AlertFilters get _nearbyFilters {
    final location = _currentLocation;
    if (location == null) return _filters;
    return _filters.nearby(
      latitude: location.latitude,
      longitude: location.longitude,
      radiusKm: _nearbyRadiusKm,
    );
  }

  Future<void> _loadAlerts({String? selectId}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final filters = _nearbyFilters;
      final results = await Future.wait([
        _mapApi.fetchAlerts(filters),
        _mapApi.fetchFilters(),
      ]);
      final alerts = results[0] as List<AlertMapItem>;
      final options = results[1] as AlertFilterOptions;
      final selected = selectId == null
          ? _findAlert(alerts, _selected?.id)
          : _findAlert(alerts, selectId);

      if (!mounted) return;
      setState(() {
        _alerts = alerts;
        _filterOptions = options;
        _selected = selected;
        _isLoading = false;
      });

      if (selected != null && selectId != null) {
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(selected.position, 12.5),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters(AlertFilters filters) {
    setState(() {
      _filters = filters;
      _selected = null;
      _selectedExplorePost = null;
    });
    _loadAlerts();
  }

  void _selectAlertFromMap(AlertMapItem alert) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selected = alert;
        _selectedExplorePost = null;
      });
    });
  }

  void _selectExplorePost(PostEntity post) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedExplorePost = post;
        _selected = null;
      });
    });
  }

  void _togglePostType(PostType type) {
    setState(() {
      final updated = Set<PostType>.from(_enabledPostTypes);
      if (updated.contains(type)) {
        updated.remove(type);
      } else {
        updated.add(type);
      }
      _enabledPostTypes = updated;
      if (_selectedExplorePost != null &&
          !updated.contains(_selectedExplorePost!.type)) {
        _selectedExplorePost = null;
      }
    });
  }

  void _openExplorePost(PostEntity post) {
    Navigator.of(context).pushNamed('/posts/${Uri.encodeComponent(post.id)}');
  }

  Future<void> _openPublishReport() async {
    final id = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PublishReportSheet(reportsApi: _reportsApi),
    );
    if (id == null || id.isEmpty) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte publicado correctamente')),
    );
    await _loadAlerts(selectId: id);
  }

  void _onBottomNavTap(int index) {
    if (index == 0) return;
    if (index == 1) Navigator.of(context).pushReplacementNamed('/publications');
    if (index == 2) _openPublishReport();
    if (index == 3) Navigator.of(context).pushReplacementNamed('/alerts');
    if (index == 4) Navigator.of(context).pushReplacementNamed('/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBody: true,
      bottomNavigationBar: MapiaBottomNavigation(
        currentIndex: 0,
        onIndexChanged: _onBottomNavTap,
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _openPublishReport,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        tooltip: 'Publicar reporte',
        child: const Icon(Icons.add_location_alt_rounded),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _MapCard(
              alerts: _alerts,
              selected: _selected,
              isLoading: _isLoading,
              error: _error,
              currentLocation: _currentLocation,
              explorePosts: _explorePosts,
              enabledPostTypes: _enabledPostTypes,
              postMarkerIcons: _postMarkerIcons,
              isMapSdkLoading: _isMapSdkLoading,
              hasLocationPermission: _hasLocationPermission,
              onMapCreated: _handleMapCreated,
              onAlertSelected: _selectAlertFromMap,
              onExplorePostSelected: _selectExplorePost,
              onRetry: _loadAlerts,
            ),
          ),
          Positioned(
            top: 0,
            left: 12,
            right: 12,
            child: SafeArea(
              bottom: false,
              child: _MapFilterBar(
                filters: _filters,
                options: _filterOptions,
                enabledPostTypes: _enabledPostTypes,
                isOpen: _filtersOpen,
                isLoading: _isLoading,
                isLocating: _isLocating,
                hasLocation: _currentLocation != null,
                onToggle: () => setState(() => _filtersOpen = !_filtersOpen),
                onRefresh: _loadAlerts,
                onLocatePressed: _handleLocatePressed,
                onPostTypeToggled: _togglePostType,
                onFiltersChanged: _applyFilters,
              ),
            ),
          ),
          if (_selectedExplorePost != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 92,
              child: MapPostPreviewCard(
                post: _selectedExplorePost!,
                onGoTap: () => _openExplorePost(_selectedExplorePost!),
              ),
            )
          else if (_selected != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 92,
              child: _SelectedAlertCard(
                alert: _selected!,
                onClose: () => setState(() => _selected = null),
              ),
            ),
        ],
      ),
    );
  }

  void _handleMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _handleLocatePressed() async {
    await _requestCurrentLocation(moveCamera: true);
    await _loadAlerts();
  }

  AlertMapItem? _findAlert(List<AlertMapItem> alerts, String? id) {
    if (id == null) return null;
    for (final alert in alerts) {
      if (alert.id == id) return alert;
    }
    return null;
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.alerts,
    required this.selected,
    required this.isLoading,
    required this.error,
    required this.currentLocation,
    required this.explorePosts,
    required this.enabledPostTypes,
    required this.postMarkerIcons,
    required this.isMapSdkLoading,
    required this.hasLocationPermission,
    required this.onMapCreated,
    required this.onAlertSelected,
    required this.onExplorePostSelected,
    required this.onRetry,
  });

  final List<AlertMapItem> alerts;
  final AlertMapItem? selected;
  final bool isLoading;
  final String? error;
  final LatLng? currentLocation;
  final List<PostEntity> explorePosts;
  final Set<PostType> enabledPostTypes;
  final PostMapMarkerIcons? postMarkerIcons;
  final bool isMapSdkLoading;
  final bool hasLocationPermission;
  final ValueChanged<GoogleMapController> onMapCreated;
  final ValueChanged<AlertMapItem> onAlertSelected;
  final ValueChanged<PostEntity> onExplorePostSelected;
  final Future<void> Function({String? selectId}) onRetry;

  @override
  Widget build(BuildContext context) {
    final missingKey = kIsWeb && AppConfig.googleMapsApiKey.isEmpty;

    return Stack(
      children: [
        Positioned.fill(
          child: missingKey
              ? const _MapStateMessage(
                  icon: Icons.key_off_rounded,
                  title: 'Falta la API key de Google Maps',
                  message:
                      'Ejecuta Flutter con GOOGLE_MAPS_API_KEY configurado.',
                )
              : isMapSdkLoading
              ? const _MapStateMessage(
                  icon: Icons.map_rounded,
                  title: 'Cargando Google Maps',
                  message: 'Preparando el mapa en esta pantalla.',
                )
              : GoogleMap(
                  onMapCreated: onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: currentLocation ?? boliviaCenter,
                    zoom: currentLocation == null ? 5.4 : 14,
                  ),
                  mapType: MapType.normal,
                  style: mapiaCleanMapStyle,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: hasLocationPermission,
                  myLocationEnabled: hasLocationPermission,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  markers: _markers(),
                  circles: _circles(),
                  onTap: (_) {},
                ),
        ),
        if (isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66FFFFFF),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        if (!isLoading && error != null)
          Positioned(
            left: 14,
            right: 14,
            top: 14,
            child: _MapNotice(
              icon: Icons.cloud_off_rounded,
              title: 'Sin conexion al backend',
              message: error!,
              action: 'Reintentar',
              onAction: () => onRetry(),
            ),
          ),
        if (!isLoading && error == null && alerts.isEmpty)
          const Positioned(
            left: 14,
            right: 14,
            top: 88,
            child: _MapNotice(
              icon: Icons.map_outlined,
              title: 'Sin alertas por ahora',
              message: 'El mapa esta listo para mostrar nuevos reportes.',
            ),
          ),
      ],
    );
  }

  Set<Marker> _markers() {
    return {
      for (final alert in alerts)
        Marker(
          markerId: MarkerId(alert.id),
          position: alert.position,
          infoWindow: InfoWindow(title: alert.title, snippet: alert.product),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            markerHue(alert.severity),
          ),
          onTap: () => onAlertSelected(alert),
        ),
      ...renderExplorePostMarkers(
        posts: explorePosts,
        enabledTypes: enabledPostTypes,
        markerIcons: postMarkerIcons,
        onTap: onExplorePostSelected,
      ),
    };
  }

  Set<Circle> _circles() {
    return {
      for (final alert in alerts)
        Circle(
          circleId: CircleId('circle_${alert.id}'),
          center: alert.position,
          radius: selected?.id == alert.id ? 760 : 520,
          fillColor: severityColor(
            alert.severity,
          ).withValues(alpha: selected?.id == alert.id ? 0.32 : 0.22),
          strokeColor: Colors.white,
          strokeWidth: selected?.id == alert.id ? 4 : 3,
          consumeTapEvents: true,
          onTap: () => onAlertSelected(alert),
        ),
    };
  }
}

class _MapFilterBar extends StatelessWidget {
  const _MapFilterBar({
    required this.filters,
    required this.options,
    required this.enabledPostTypes,
    required this.isOpen,
    required this.isLoading,
    required this.isLocating,
    required this.hasLocation,
    required this.onToggle,
    required this.onRefresh,
    required this.onLocatePressed,
    required this.onPostTypeToggled,
    required this.onFiltersChanged,
  });

  final AlertFilters filters;
  final AlertFilterOptions options;
  final Set<PostType> enabledPostTypes;
  final bool isOpen;
  final bool isLoading;
  final bool isLocating;
  final bool hasLocation;
  final VoidCallback onToggle;
  final Future<void> Function({String? selectId}) onRefresh;
  final Future<void> Function() onLocatePressed;
  final ValueChanged<PostType> onPostTypeToggled;
  final ValueChanged<AlertFilters> onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    final activeFilters = _activeFilterCount(filters);
    final compact = MediaQuery.sizeOf(context).width < 520;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              if (!compact)
                const Expanded(
                  child: Text(
                    'Mapa de alertas',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              else
                const Spacer(),
              TextButton.icon(
                onPressed: onToggle,
                icon: Icon(
                  isOpen ? Icons.keyboard_arrow_up_rounded : Icons.tune_rounded,
                ),
                label: Text(
                  activeFilters == 0 ? 'Categorias' : 'Filtros $activeFilters',
                ),
              ),
              IconButton(
                tooltip: hasLocation
                    ? 'Actualizar ubicacion'
                    : 'Usar ubicacion',
                onPressed: isLocating ? null : onLocatePressed,
                color: hasLocation
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
                icon: isLocating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded),
              ),
              IconButton(
                tooltip: 'Actualizar',
                onPressed: isLoading ? null : () => onRefresh(),
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: isOpen
              ? _FilterDropdown(
                  key: const ValueKey('filters-open'),
                  filters: filters,
                  options: options,
                  enabledPostTypes: enabledPostTypes,
                  onPostTypeToggled: onPostTypeToggled,
                  onFiltersChanged: onFiltersChanged,
                )
              : const SizedBox.shrink(key: ValueKey('filters-closed')),
        ),
      ],
    );
  }

  int _activeFilterCount(AlertFilters filters) {
    var count = 0;
    if (filters.department != null) count++;
    if (filters.municipality != null) count++;
    if (filters.zone != null) count++;
    if (filters.product != null) count++;
    if (filters.alertType != null) count++;
    if (filters.severity != null) count++;
    return count;
  }
}

class _MapCategoryFilters extends StatelessWidget {
  const _MapCategoryFilters({
    required this.enabledTypes,
    required this.onTypeToggled,
  });

  final Set<PostType> enabledTypes;
  final ValueChanged<PostType> onTypeToggled;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final type in PostType.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: enabledTypes.contains(type),
                onSelected: (_) => onTypeToggled(type),
                avatar: Icon(
                  type.option.icon,
                  size: 17,
                  color: type.option.color,
                ),
                label: Text(type.option.label),
                showCheckmark: false,
                backgroundColor: Colors.white.withValues(alpha: 0.94),
                selectedColor: type.option.color.withValues(alpha: 0.14),
                side: BorderSide(
                  color: enabledTypes.contains(type)
                      ? type.option.color.withValues(alpha: 0.55)
                      : const Color(0xFFE2E8F0),
                ),
                labelStyle: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    super.key,
    required this.filters,
    required this.options,
    required this.enabledPostTypes,
    required this.onPostTypeToggled,
    required this.onFiltersChanged,
  });

  final AlertFilters filters;
  final AlertFilterOptions options;
  final Set<PostType> enabledPostTypes;
  final ValueChanged<PostType> onPostTypeToggled;
  final ValueChanged<AlertFilters> onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      constraints: BoxConstraints(
        maxHeight: (MediaQuery.sizeOf(context).height * 0.58).clamp(
          280.0,
          460.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppTheme.softShadow,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categorias de publicaciones',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            _MapCategoryFilters(
              enabledTypes: enabledPostTypes,
              onTypeToggled: onPostTypeToggled,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filtros de alertas',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (!filters.isEmpty)
                  TextButton(
                    onPressed: () => onFiltersChanged(const AlertFilters()),
                    child: const Text('Limpiar'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _StringFilter(
              label: 'Departamento',
              value: filters.department,
              values: options.departments,
              onChanged: (value) => onFiltersChanged(
                filters.copyWith(
                  department: value,
                  clearDepartment: value == null,
                ),
              ),
            ),
            _StringFilter(
              label: 'Municipio',
              value: filters.municipality,
              values: options.municipalities,
              onChanged: (value) => onFiltersChanged(
                filters.copyWith(
                  municipality: value,
                  clearMunicipality: value == null,
                ),
              ),
            ),
            _StringFilter(
              label: 'Zona',
              value: filters.zone,
              values: options.zones,
              onChanged: (value) => onFiltersChanged(
                filters.copyWith(zone: value, clearZone: value == null),
              ),
            ),
            _StringFilter(
              label: 'Producto',
              value: filters.product,
              values: options.products,
              onChanged: (value) => onFiltersChanged(
                filters.copyWith(product: value, clearProduct: value == null),
              ),
            ),
            _EnumFilter<AlertType>(
              label: 'Tipo de problema',
              value: filters.alertType,
              values: options.alertTypes.isEmpty
                  ? AlertType.values
                  : options.alertTypes,
              labelOf: (value) => value.label,
              onChanged: (value) => onFiltersChanged(
                filters.copyWith(
                  alertType: value,
                  clearAlertType: value == null,
                ),
              ),
            ),
            _EnumFilter<AlertSeverity>(
              label: 'Severidad',
              value: filters.severity,
              values: options.severities.isEmpty
                  ? AlertSeverity.values
                  : options.severities,
              labelOf: (value) => value.label,
              onChanged: (value) => onFiltersChanged(
                filters.copyWith(severity: value, clearSeverity: value == null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapNotice extends StatelessWidget {
  const _MapNotice({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (action != null && onAction != null) ...[
            const SizedBox(width: 8),
            TextButton(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}

class _MapStateMessage extends StatelessWidget {
  const _MapStateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: const Color(0xFF64748B)),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StringFilter extends StatelessWidget {
  const _StringFilter({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: values.contains(value) ? value : null,
        decoration: InputDecoration(labelText: label),
        items: [
          const DropdownMenuItem(value: null, child: Text('Todos')),
          ...values.map(
            (value) => DropdownMenuItem(value: value, child: Text(value)),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _EnumFilter<T> extends StatelessWidget {
  const _EnumFilter({
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> values;
  final String Function(T value) labelOf;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<T>(
        initialValue: values.contains(value) ? value : null,
        decoration: InputDecoration(labelText: label),
        items: [
          DropdownMenuItem<T>(value: null, child: const Text('Todos')),
          ...values.map(
            (value) =>
                DropdownMenuItem(value: value, child: Text(labelOf(value))),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _SelectedAlertCard extends StatelessWidget {
  const _SelectedAlertCard({required this.alert, required this.onClose});

  final AlertMapItem alert;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: severityColor(alert.severity),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  alert.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    alert.product ?? 'Producto no especificado',
                    alert.alertType.label,
                    alert.severity.label,
                  ].join(' - '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    alert.municipality ?? alert.department ?? 'Bolivia',
                    '${(alert.confidence * 100).round()}% confianza',
                  ].join(' - '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cerrar detalle',
            visualDensity: VisualDensity.compact,
            onPressed: onClose,
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishReportSheet extends StatefulWidget {
  const _PublishReportSheet({required this.reportsApi});

  final ReportsApi reportsApi;

  @override
  State<_PublishReportSheet> createState() => _PublishReportSheetState();
}

class _PublishReportSheetState extends State<_PublishReportSheet> {
  final _picker = ImagePicker();
  final _speech = SpeechToText();
  final _sourceController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productController = TextEditingController();
  final _priceController = TextEditingController();
  final _departmentController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _zoneController = TextEditingController();

  AlertType _alertType = AlertType.stockBajo;
  AlertSeverity _severity = AlertSeverity.medium;
  LatLng _location = boliviaCenter;
  double _confidence = 0.75;
  List<XFile> _images = [];
  bool _isParsing = false;
  bool _isPublishing = false;
  bool _isListening = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _productController.dispose();
    _priceController.dispose();
    _departmentController.dispose();
    _municipalityController.dispose();
    _zoneController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _requestLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!isInsideBolivia(position.latitude, position.longitude)) return;
      _setLocation(LatLng(position.latitude, position.longitude));
    } catch (_) {
      return;
    }
  }

  void _setLocation(LatLng location) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _location = location);
    });
  }

  Future<void> _toggleVoice() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize();
    if (!available) {
      setState(() => _error = 'No se pudo iniciar el dictado por voz');
      return;
    }

    setState(() {
      _isListening = true;
      _error = null;
    });
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'es_BO'),
      onResult: (result) {
        setState(() => _sourceController.text = result.recognizedWords);
      },
    );
  }

  Future<void> _parseReport() async {
    final text = _sourceController.text.trim();
    if (text.length < 5) {
      setState(() => _error = 'Escribe o dicta un reporte primero');
      return;
    }

    setState(() {
      _isParsing = true;
      _error = null;
    });

    try {
      final parsed = await widget.reportsApi.parseReport(
        text: text,
        latitude: _location.latitude,
        longitude: _location.longitude,
      );
      setState(() {
        _titleController.text = parsed.title;
        _descriptionController.text = parsed.description;
        _productController.text = parsed.product;
        _priceController.text = parsed.price?.toString() ?? '';
        _departmentController.text = parsed.department ?? '';
        _municipalityController.text = parsed.municipality ?? '';
        _zoneController.text = parsed.zone ?? '';
        _alertType = parsed.alertType;
        _severity = parsed.severity;
        _confidence = parsed.confidence;
        _isParsing = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isParsing = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final remaining = 3 - _images.length;
    if (remaining <= 0) return;
    final picked = await _picker.pickMultiImage(limit: remaining);
    final valid = <XFile>[];
    for (final image in picked) {
      final bytes = await image.length();
      final lower = image.name.toLowerCase();
      final allowed =
          lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.webp');
      if (bytes <= 5 * 1024 * 1024 && allowed) valid.add(image);
    }
    setState(() {
      _images = [..._images, ...valid].take(3).toList();
      if (valid.length != picked.length) {
        _error = 'Algunas imagenes fueron omitidas por formato o tamano';
      }
    });
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    if (title.length < 3) {
      setState(() => _error = 'El titulo es obligatorio');
      return;
    }
    if (!isInsideBolivia(_location.latitude, _location.longitude)) {
      setState(() => _error = 'La ubicacion debe estar dentro de Bolivia');
      return;
    }

    setState(() {
      _isPublishing = true;
      _error = null;
    });

    try {
      final id = await widget.reportsApi.publishReport(
        PublishReportInput(
          title: title,
          description: _descriptionController.text.trim(),
          product: _productController.text.trim(),
          alertType: _alertType,
          severity: _severity,
          latitude: _location.latitude,
          longitude: _location.longitude,
          department: _departmentController.text.trim(),
          municipality: _municipalityController.text.trim(),
          zone: _zoneController.text.trim(),
          price: double.tryParse(_priceController.text.replaceAll(',', '.')),
          sourceText: _sourceController.text.trim(),
          confidence: _confidence,
          images: _images,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(id);
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isPublishing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.94,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          14,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Publicar reporte',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sourceController,
              minLines: 4,
              maxLines: 7,
              decoration: const InputDecoration(
                labelText: 'Escribir reporte',
                hintText: 'En el mercado Rodriguez el azucar subio a 9 Bs...',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _toggleVoice,
                    icon: Icon(
                      _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    ),
                    label: Text(
                      _isListening ? 'Detener dictado' : 'Dictar con voz',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isParsing ? null : _parseReport,
                    icon: _isParsing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Analizar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SheetSection(
              title: 'Datos detectados',
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Titulo'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Descripcion'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _productController,
                          decoration: const InputDecoration(
                            labelText: 'Producto',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Precio Bs',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<AlertType>(
                    initialValue: _alertType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de alerta',
                    ),
                    items: AlertType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _alertType = value ?? _alertType),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<AlertSeverity>(
                    initialValue: _severity,
                    decoration: const InputDecoration(labelText: 'Severidad'),
                    items: AlertSeverity.values
                        .map(
                          (severity) => DropdownMenuItem(
                            value: severity,
                            child: Text(severity.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _severity = value ?? _severity),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Departamento',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _municipalityController,
                    decoration: const InputDecoration(labelText: 'Municipio'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _zoneController,
                    decoration: const InputDecoration(labelText: 'Zona'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SheetSection(
              title: 'Ubicacion',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb && AppConfig.googleMapsApiKey.isEmpty
                          ? const _MapStateMessage(
                              icon: Icons.key_off_rounded,
                              title: 'Configura Google Maps',
                              message:
                                  'No se puede seleccionar el punto sin API key.',
                            )
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _location,
                                zoom: 13,
                              ),
                              style: mapiaCleanMapStyle,
                              markers: {
                                Marker(
                                  markerId: const MarkerId('report_location'),
                                  position: _location,
                                  draggable: true,
                                  onDragEnd: _setLocation,
                                ),
                              },
                              onTap: _setLocation,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lat ${_location.latitude.toStringAsFixed(5)}, Lng ${_location.longitude.toStringAsFixed(5)}',
                    style: TextStyle(
                      color:
                          isInsideBolivia(
                            _location.latitude,
                            _location.longitude,
                          )
                          ? const Color(0xFF64748B)
                          : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _requestLocation,
                    icon: const Icon(Icons.my_location_rounded),
                    label: const Text('Usar ubicacion actual'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SheetSection(
              title: 'Imagenes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: _images.length >= 3 ? null : _pickImages,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Agregar imagenes'),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final image in _images)
                        _ImagePreview(
                          image: image,
                          onRemove: () => setState(
                            () => _images = _images
                                .where((item) => item != image)
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isPublishing ? null : _publish,
              icon: _isPublishing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.publish_rounded),
              label: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  const _SheetSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, required this.onRemove});

  final XFile image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (context, snapshot) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: snapshot.hasData
                  ? Image.memory(
                      snapshot.data!,
                      width: 86,
                      height: 86,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 86,
                      height: 86,
                      color: const Color(0xFFE2E8F0),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: IconButton.filledTonal(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 16),
                constraints: const BoxConstraints.tightFor(
                  width: 30,
                  height: 30,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        );
      },
    );
  }
}
