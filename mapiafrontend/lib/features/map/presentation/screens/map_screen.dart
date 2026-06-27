import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapiafrontend/core/config/app_config.dart';
import 'package:mapiafrontend/core/platform/google_maps_web_loader.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/chatbot/widgets/floating_chatbot_button.dart';
import 'package:mapiafrontend/core/network/authenticated_api_client.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_gate.dart';
import 'package:mapiafrontend/features/map/domain/models/map_filter_model.dart';
import 'package:mapiafrontend/features/map/domain/entities/map_publication_marker_entity.dart';
import 'package:mapiafrontend/features/map/presentation/widgets/news_map_card.dart';
import 'package:mapiafrontend/features/map/presentation/widgets/map_filter_chips.dart';
import 'package:mapiafrontend/features/map/presentation/widgets/map_marker_builder.dart';
import 'package:mapiafrontend/features/map/presentation/widgets/map_post_preview_card.dart';
import 'package:mapiafrontend/features/map/services/map_api.dart';
import 'package:mapiafrontend/features/map/services/news_map_api.dart';
import 'package:mapiafrontend/features/map/services/reports_api.dart';
import 'package:mapiafrontend/features/map/services/routing_api.dart';
import 'package:mapiafrontend/features/reports/data/analyzed_report.dart';
import 'package:mapiafrontend/features/reports/data/optional_fields_by_category.dart';
import 'package:mapiafrontend/features/reports/presentation/widgets/dynamic_optional_fields_widget.dart';
import 'package:mapiafrontend/features/map/styles/mapia_map_style.dart';
import 'package:mapiafrontend/features/map/types/alert_map_types.dart';
import 'package:mapiafrontend/features/map/utils/alert_marker_icons.dart';
import 'package:mapiafrontend/features/map/utils/bolivia_bounds.dart';
import 'package:mapiafrontend/features/map/utils/severity.dart';
import 'package:mapiafrontend/features/news/domain/entities/map_news_item.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';
import 'package:mapiafrontend/shared/widgets/mapia_bottom_navigation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.openCreateEvent = false});

  final bool openCreateEvent;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapApi? _mapApi;
  ReportsApi? _reportsApi;
  NewsMapApi? _newsMapApi;
  RoutingApi? _routingApi;

  // Ruta que evita bloqueos.
  LatLng? _destination;
  RouteResult? _routeInfo;
  Set<Polyline> _routePolylines = {};
  bool _isRouting = false;
  String? _routeError;

  GoogleMapController? _mapController;
  AlertFilters _filters = const AlertFilters();
  MapLayerFilters _layerFilters = const MapLayerFilters();
  AlertFilterOptions _filterOptions = const AlertFilterOptions();
  List<AlertMapItem> _alerts = [];
  List<MapNewsItem> _mapNews = [];
  List<MapPublicationMarkerEntity> _publications = [];
  AlertMapItem? _selected;
  MapNewsItem? _selectedNews;
  MapPublicationMarkerEntity? _selectedPublication;
  AlertMapMarkerIcons? _alertMarkerIcons;
  bool _isLoading = true;
  bool _isLocating = true;
  bool _isMapSdkLoading = kIsWeb && AppConfig.googleMapsApiKey.isNotEmpty;
  bool _hasLocationPermission = false;
  bool _filtersOpen = false;
  String? _error;
  LatLng? _currentLocation;
  Timer? _refreshTimer;
  Timer? _newsRefreshTimer;
  String? _activeUserId;
  String? _pendingNewsId;
  String? _pendingAlertId;
  LatLng? _pendingFocus;
  bool _pendingOpenCreateEvent = false;
  bool _didOpenInitialCreateEvent = false;

  void _bindToUser() {
    final auth = AuthScope.of(context);
    final userId = auth.user?.id;
    if (userId == null || userId == _activeUserId) return;

    _refreshTimer?.cancel();
    _newsRefreshTimer?.cancel();
    _activeUserId = userId;
    final client = createAuthenticatedApiClient(auth);
    _mapApi = MapApi(client: client);
    _reportsApi = ReportsApi(client: client);
    _newsMapApi = NewsMapApi();
    _routingApi = RoutingApi(client: client);
    final args = ModalRoute.of(context)?.settings.arguments;
    _pendingNewsId = args is Map ? args['newsId'] as String? : null;
    _pendingAlertId = args is Map ? args['alertId'] as String? : null;
    _pendingOpenCreateEvent =
        widget.openCreateEvent ||
        (args is Map && args['openCreateEvent'] == true);
    final focusLat = args is Map ? args['lat'] : null;
    final focusLng = args is Map ? args['lng'] : null;
    _pendingFocus = (focusLat is num && focusLng is num)
        ? LatLng(focusLat.toDouble(), focusLng.toDouble())
        : null;
    setState(() {
      _selected = null;
      _selectedNews = null;
      _selectedPublication = null;
      _alerts = [];
      _mapNews = [];
      _publications = [];
      _isLoading = true;
    });
    _initializeMap();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_isLoading && _error == null) {
        _loadAlertsQuietly();
      }
    });
    _newsRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _loadMapNewsQuietly();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bindToUser();
  }

  @override
  void initState() {
    super.initState();
    _loadAlertMarkerIcons();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _newsRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    await _loadGoogleMapsSdk();
    await _requestCurrentLocation();
    await Future.wait([
      _loadAlerts(selectId: _pendingAlertId),
      _loadMapNews(),
      _loadMapPublications(),
    ]);
    if (_pendingAlertId != null) {
      _pendingFocus = _selected?.position ?? _pendingFocus;
      _pendingAlertId = null;
      await _applyPendingFocus();
    }
    _openInitialCreateEventIfNeeded();
  }

  void _openInitialCreateEventIfNeeded() {
    if (!_pendingOpenCreateEvent ||
        _didOpenInitialCreateEvent ||
        _reportsApi == null) {
      return;
    }
    _didOpenInitialCreateEvent = true;
    _pendingOpenCreateEvent = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openPublishReport();
    });
  }

  /// Centra la cÃ¡mara en la incidencia indicada al navegar desde el chatbot.
  /// Si el controlador aÃºn no existe, se aplica luego en [_handleMapCreated].
  Future<void> _applyPendingFocus() async {
    final target = _pendingFocus;
    if (target == null || _mapController == null) return;
    _pendingFocus = null;
    await _mapController!.animateCamera(CameraUpdate.newLatLngZoom(target, 14));
  }

  Future<void> _loadAlertMarkerIcons() async {
    final icons = await AlertMapMarkerIcons.create();
    if (!mounted) return;
    setState(() => _alertMarkerIcons = icons);
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

  Future<void> _loadAlertsQuietly() async {
    try {
      final results = await Future.wait([
        _mapApi!.fetchAlerts(_filters),
        _mapApi!.fetchFilters(),
        _mapApi!.fetchPublications(),
      ]);
      if (!mounted) return;
      setState(() {
        _alerts = results[0] as List<AlertMapItem>;
        _filterOptions = results[1] as AlertFilterOptions;
        _publications = results[2] as List<MapPublicationMarkerEntity>;
      });
    } catch (_) {}
  }

  Future<void> _loadMapNewsQuietly() async {
    try {
      final items = await _newsMapApi!.fetchTodayMapNews();
      if (!mounted) return;
      setState(() {
        _mapNews = items;
        _selectedNews = _findNews(items, _selectedNews?.id);
      });
    } catch (_) {}
  }

  Future<void> _loadMapPublications() async {
    try {
      final items = await _fetchVisiblePublications();
      if (!mounted) return;
      setState(() {
        _publications = items;
        _selectedPublication = _findPublication(
          items,
          _selectedPublication?.publicationId,
        );
      });
    } catch (_) {}
  }

  Future<List<MapPublicationMarkerEntity>> _fetchVisiblePublications() async {
    final controller = _mapController;
    if (controller == null) {
      return _mapApi!.fetchPublications();
    }
    final bounds = await controller.getVisibleRegion();
    return _mapApi!.fetchPublications(
      north: bounds.northeast.latitude,
      south: bounds.southwest.latitude,
      east: bounds.northeast.longitude,
      west: bounds.southwest.longitude,
    );
  }

  Future<void> _loadAlerts({String? selectId}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _mapApi!.fetchAlerts(_filters),
        _mapApi!.fetchFilters(),
        _mapApi!.fetchPublications(),
      ]);
      final alerts = results[0] as List<AlertMapItem>;
      final options = results[1] as AlertFilterOptions;
      final publications = results[2] as List<MapPublicationMarkerEntity>;
      final selected = selectId == null
          ? _findAlert(alerts, _selected?.id)
          : _findAlert(alerts, selectId);

      if (!mounted) return;
      setState(() {
        _alerts = alerts;
        _publications = publications;
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

  Future<void> _loadMapNews() async {
    try {
      final items = await _newsMapApi!.fetchTodayMapNews();
      final selected = _findNews(items, _pendingNewsId);
      if (!mounted) return;
      setState(() {
        _mapNews = items;
        if (selected != null) {
          _selectedNews = selected;
          _selected = null;
        }
      });
      if (selected != null) {
        _pendingNewsId = null;
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(selected.position, 13),
        );
      }
    } catch (_) {}
  }

  void _applyFilters(AlertFilters filters) {
    setState(() {
      _filters = filters;
      _selected = null;
      _selectedNews = null;
      _selectedPublication = null;
    });
    _loadAlerts();
  }

  void _toggleLayerFilter(MapFilterCategory category) {
    setState(() {
      _layerFilters = _layerFilters.toggled(category);
      _clearHiddenSelection();
    });
  }

  void _clearLayerFilters() {
    setState(() {
      _layerFilters = _layerFilters.clear();
      _clearHiddenSelection();
    });
  }

  void _selectAlertFromMap(AlertMapItem alert) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selected = alert;
        _selectedNews = null;
        _selectedPublication = null;
      });
    });
  }

  void _selectNewsFromMap(MapNewsItem item) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedNews = item;
        _selected = null;
        _selectedPublication = null;
      });
    });
  }

  void _selectPublicationFromMap(MapPublicationMarkerEntity item) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedPublication = item;
        _selected = null;
        _selectedNews = null;
      });
    });
  }

  void _openPublication(MapPublicationMarkerEntity item) {
    Navigator.of(
      context,
    ).pushNamed('/posts/${Uri.encodeComponent(item.publicationId)}');
  }

  Future<void> _openNewsUrl(MapNewsItem item) async {
    final url = item.url;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _refreshMapData() async {
    await Future.wait([_loadAlerts(), _loadMapNews(), _loadMapPublications()]);
  }

  // --- Ruta que evita bloqueos -------------------------------------------------

  Future<void> _onMapLongPressed(LatLng destination) async {
    final origin = _currentLocation;
    if (origin == null) {
      setState(() => _routeError = 'Activa tu ubicaciÃ³n para trazar la ruta');
      return;
    }
    setState(() {
      _destination = destination;
      _isRouting = true;
      _routeError = null;
    });

    try {
      final result = await _routingApi!.route(
        origin: origin,
        destination: destination,
      );
      if (!mounted) return;
      setState(() {
        _routeInfo = result;
        _routePolylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: result.points,
            width: 6,
            color: result.avoidedBlockades
                ? const Color(0xFF2563EB)
                : const Color(0xFFEF4444),
          ),
        };
        _isRouting = false;
      });
      if (result.points.isNotEmpty) {
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(_boundsOf(result.points), 60),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isRouting = false;
        _routeError = 'No se pudo trazar la ruta';
        _routeInfo = null;
        _routePolylines = {};
      });
    }
  }

  void _clearRoute() {
    setState(() {
      _destination = null;
      _routeInfo = null;
      _routePolylines = {};
      _routeError = null;
    });
  }

  Set<Marker> _routeMarkers() {
    final markers = <Marker>{};
    final dest = _destination;
    if (dest != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('route_destination'),
          position: dest,
          infoWindow: const InfoWindow(title: 'Destino'),
        ),
      );
    }
    for (final b in _routeInfo?.blockades ?? const []) {
      markers.add(
        Marker(
          markerId: MarkerId(
            'block_${b.position.latitude}_${b.position.longitude}',
          ),
          position: b.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: b.title,
            snippet: 'ObstrucciÃ³n: ${b.category}',
          ),
        ),
      );
    }
    return markers;
  }

  LatLngBounds _boundsOf(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final p in points) {
      minLat = p.latitude < minLat ? p.latitude : minLat;
      maxLat = p.latitude > maxLat ? p.latitude : maxLat;
      minLng = p.longitude < minLng ? p.longitude : minLng;
      maxLng = p.longitude > maxLng ? p.longitude : maxLng;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _openPublishReport() async {
    final id = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PublishReportSheet(reportsApi: _reportsApi!),
    );
    if (id == null || id.isEmpty) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte publicado correctamente')),
    );
    await _loadAlerts(selectId: id);
  }

  Future<void> _deleteReport(String id) async {
    try {
      await _reportsApi!.deleteReport(id);
      if (!mounted) return;
      setState(() {
        if (_selected?.id == id) _selected = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reporte eliminado')));
      await _loadAlerts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 0) return;
    if (index == 1) Navigator.of(context).pushReplacementNamed('/publications');
    if (index == 2) Navigator.of(context).pushReplacementNamed('/alerts');
    if (index == 3) Navigator.of(context).pushReplacementNamed('/profile');
  }

  @override
  Widget build(BuildContext context) {
    final visibleAlerts = _visibleAlerts();
    final visibleNews = _visibleNews();
    final visiblePublications = _visiblePublications();
    final availableCategories = _availableCategories();
    final bool isCardOpen =
        _selected != null ||
        _selectedNews != null ||
        _selectedPublication != null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FloatingChatbotButton.isVisible.value != !isCardOpen) {
        FloatingChatbotButton.isVisible.value = !isCardOpen;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBody: true,
      bottomNavigationBar: MapiaBottomNavigation(
        currentIndex: 0,
        onIndexChanged: _onBottomNavTap,
      ),
      floatingActionButton: isCardOpen
          ? null
          : FloatingActionButton.small(
              onPressed: _openPublishReport,
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              tooltip: 'Crear evento',
              child: const Icon(Icons.add_location_alt_rounded),
            ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _MapCard(
              alerts: visibleAlerts,
              news: visibleNews,
              publications: visiblePublications,
              selected: _selected,
              selectedNews: _selectedNews,
              selectedPublication: _selectedPublication,
              alertMarkerIcons: _alertMarkerIcons,
              isLoading: _isLoading,
              error: _error,
              currentLocation: _currentLocation,
              isMapSdkLoading: _isMapSdkLoading,
              hasLocationPermission: _hasLocationPermission,
              hasActiveLayerFilters: !_layerFilters.isEmpty,
              onMapCreated: _handleMapCreated,
              onAlertSelected: _selectAlertFromMap,
              onNewsSelected: _selectNewsFromMap,
              onPublicationSelected: _selectPublicationFromMap,
              onCameraIdle: _loadMapPublications,
              onMapTapped: () => setState(() {
                _selected = null;
                _selectedNews = null;
                _selectedPublication = null;
              }),
              onRetry: ({selectId}) => _refreshMapData(),
              routePolylines: _routePolylines,
              routeMarkers: _routeMarkers(),
              onMapLongPressed: _onMapLongPressed,
            ),
          ),
          if (_isRouting || _routeInfo != null || _routeError != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 24,
              child: SafeArea(
                top: false,
                child: _RouteBanner(
                  isLoading: _isRouting,
                  route: _routeInfo,
                  error: _routeError,
                  onClose: _clearRoute,
                ),
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
                layerFilters: _layerFilters,
                options: _filterOptions,
                availableCategories: availableCategories,
                isOpen: _filtersOpen,
                isLoading: _isLoading,
                isLocating: _isLocating,
                hasLocation: _currentLocation != null,
                onToggle: () => setState(() => _filtersOpen = !_filtersOpen),
                onRefresh: ({selectId}) => _refreshMapData(),
                onLocatePressed: _handleLocatePressed,
                onFiltersChanged: _applyFilters,
                onLayerFilterToggled: _toggleLayerFilter,
                onLayerFiltersCleared: _clearLayerFilters,
              ),
            ),
          ),
          if (_selectedNews != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 125,
              child: NewsMapCard(
                item: _selectedNews!,
                onOpen: (_selectedNews!.url?.isNotEmpty ?? false)
                    ? () => _openNewsUrl(_selectedNews!)
                    : null,
                onClose: () => setState(() => _selectedNews = null),
              ),
            )
          else if (_selectedPublication != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 125,
              child: MapPostPreviewCard(
                post: _selectedPublication!.toPreviewPost(),
                onGoTap: () => _openPublication(_selectedPublication!),
                onClose: () => setState(() => _selectedPublication = null),
              ),
            )
          else if (_selected != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 125,
              child: _SelectedAlertCard(
                alert: _selected!,
                isMyReport: _selected!.isMine,
                onDelete: () => _deleteReport(_selected!.id),
                onClose: () => setState(() => _selected = null),
              ),
            ),
        ],
      ),
    );
  }

  void _handleMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final selected = _selectedNews;
    if (selected != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(selected.position, 13),
      );
      return;
    }
    // Si se llegÃ³ al mapa desde el chatbot antes de que el mapa existiera.
    if (_selected != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_selected!.position, 14),
      );
      return;
    }
    _applyPendingFocus();
  }

  Future<void> _handleLocatePressed() async {
    await _requestCurrentLocation(moveCamera: true);
    await _refreshMapData();
  }

  AlertMapItem? _findAlert(List<AlertMapItem> alerts, String? id) {
    if (id == null) return null;
    for (final alert in alerts) {
      if (alert.id == id) return alert;
    }
    return null;
  }

  MapNewsItem? _findNews(List<MapNewsItem> items, String? id) {
    if (id == null) return null;
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  MapPublicationMarkerEntity? _findPublication(
    List<MapPublicationMarkerEntity> items,
    String? id,
  ) {
    if (id == null) return null;
    for (final item in items) {
      if (item.publicationId == id) return item;
    }
    return null;
  }

  List<AlertMapItem> _visibleAlerts() {
    if (!_layerFilters.allows(MapFilterCategory.citizenReports)) {
      return const [];
    }
    return _alerts;
  }

  List<MapNewsItem> _visibleNews() {
    if (!_layerFilters.allows(MapFilterCategory.news)) {
      return const [];
    }
    return _mapNews;
  }

  List<MapPublicationMarkerEntity> _visiblePublications() {
    if (!_layerFilters.allows(MapFilterCategory.userPosts)) {
      return const [];
    }
    return _publications;
  }

  Set<MapFilterCategory> _availableCategories() {
    return {
      if (_alerts.isNotEmpty) MapFilterCategory.citizenReports,
      if (_mapNews.isNotEmpty) MapFilterCategory.news,
      if (_publications.isNotEmpty) MapFilterCategory.userPosts,
    };
  }

  void _clearHiddenSelection() {
    if (_selected != null &&
        !_layerFilters.allows(MapFilterCategory.citizenReports)) {
      _selected = null;
    }
    if (_selectedNews != null &&
        !_layerFilters.allows(MapFilterCategory.news)) {
      _selectedNews = null;
    }
    if (_selectedPublication != null &&
        !_layerFilters.allows(MapFilterCategory.userPosts)) {
      _selectedPublication = null;
    }
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.alerts,
    required this.news,
    required this.publications,
    required this.selected,
    required this.selectedNews,
    required this.selectedPublication,
    required this.alertMarkerIcons,
    required this.isLoading,
    required this.error,
    required this.currentLocation,
    required this.isMapSdkLoading,
    required this.hasLocationPermission,
    required this.hasActiveLayerFilters,
    required this.onMapCreated,
    required this.onAlertSelected,
    required this.onNewsSelected,
    required this.onPublicationSelected,
    required this.onCameraIdle,
    required this.onMapTapped,
    required this.onRetry,
    required this.routePolylines,
    required this.routeMarkers,
    required this.onMapLongPressed,
  });

  final List<AlertMapItem> alerts;
  final List<MapNewsItem> news;
  final List<MapPublicationMarkerEntity> publications;
  final AlertMapItem? selected;
  final MapNewsItem? selectedNews;
  final MapPublicationMarkerEntity? selectedPublication;
  final AlertMapMarkerIcons? alertMarkerIcons;
  final bool isLoading;
  final String? error;
  final LatLng? currentLocation;
  final bool isMapSdkLoading;
  final bool hasLocationPermission;
  final bool hasActiveLayerFilters;
  final ValueChanged<GoogleMapController> onMapCreated;
  final ValueChanged<AlertMapItem> onAlertSelected;
  final ValueChanged<MapNewsItem> onNewsSelected;
  final ValueChanged<MapPublicationMarkerEntity> onPublicationSelected;
  final VoidCallback onCameraIdle;
  final VoidCallback onMapTapped;
  final Future<void> Function({String? selectId}) onRetry;
  final Set<Polyline> routePolylines;
  final Set<Marker> routeMarkers;
  final ValueChanged<LatLng> onMapLongPressed;

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
                  myLocationButtonEnabled: false,
                  myLocationEnabled: hasLocationPermission,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  markers: {..._markers(), ...routeMarkers},
                  circles: _circles(),
                  polylines: routePolylines,
                  onCameraIdle: onCameraIdle,
                  onTap: (_) => onMapTapped(),
                  onLongPress: onMapLongPressed,
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
        if (!isLoading &&
            error == null &&
            alerts.isEmpty &&
            news.isEmpty &&
            publications.isEmpty)
          Positioned(
            left: 14,
            right: 14,
            top: 88,
            child: _MapNotice(
              icon: Icons.map_outlined,
              title: hasActiveLayerFilters
                  ? 'No hay elementos para estos filtros'
                  : 'No hay novedades geolocalizadas por hoy',
              message: hasActiveLayerFilters
                  ? 'Prueba otra categoria o limpia los filtros del mapa.'
                  : 'El mapa esta listo para mostrar reportes y novedades nuevas.',
            ),
          ),
      ],
    );
  }

  Set<Marker> _markers() {
    return _markerBuilder().markers();
  }

  Set<Circle> _circles() {
    return _markerBuilder().circles();
  }

  MapMarkerBuilder _markerBuilder() {
    return MapMarkerBuilder(
      alerts: alerts,
      news: news,
      publications: publications,
      selectedAlert: selected,
      selectedNews: selectedNews,
      selectedPublication: selectedPublication,
      alertMarkerIcons: alertMarkerIcons,
      onAlertSelected: onAlertSelected,
      onNewsSelected: onNewsSelected,
      onPublicationSelected: onPublicationSelected,
    );
  }
}

class _MapFilterBar extends StatelessWidget {
  const _MapFilterBar({
    required this.filters,
    required this.layerFilters,
    required this.options,
    required this.availableCategories,
    required this.isOpen,
    required this.isLoading,
    required this.isLocating,
    required this.hasLocation,
    required this.onToggle,
    required this.onRefresh,
    required this.onLocatePressed,
    required this.onFiltersChanged,
    required this.onLayerFilterToggled,
    required this.onLayerFiltersCleared,
  });

  final AlertFilters filters;
  final MapLayerFilters layerFilters;
  final AlertFilterOptions options;
  final Set<MapFilterCategory> availableCategories;
  final bool isOpen;
  final bool isLoading;
  final bool isLocating;
  final bool hasLocation;
  final VoidCallback onToggle;
  final Future<void> Function({String? selectId}) onRefresh;
  final Future<void> Function() onLocatePressed;
  final ValueChanged<AlertFilters> onFiltersChanged;
  final ValueChanged<MapFilterCategory> onLayerFilterToggled;
  final VoidCallback onLayerFiltersCleared;

  @override
  Widget build(BuildContext context) {
    final activeFilters =
        _activeFilterCount(filters) + layerFilters.activeCount;

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
              TextButton.icon(
                onPressed: onToggle,
                icon: Icon(
                  isOpen ? Icons.keyboard_arrow_up_rounded : Icons.tune_rounded,
                ),
                label: Text(
                  activeFilters == 0 ? 'Filtros' : 'Filtros $activeFilters',
                ),
              ),
              const Spacer(),
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
            ],
          ),
        ),
        MapFilterChips(
          filters: layerFilters,
          availableCategories: availableCategories,
          onToggle: onLayerFilterToggled,
          onClear: onLayerFiltersCleared,
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

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    super.key,
    required this.filters,
    required this.options,
    required this.onFiltersChanged,
  });

  final AlertFilters filters;
  final AlertFilterOptions options;
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
  const _SelectedAlertCard({
    required this.alert,
    required this.isMyReport,
    required this.onDelete,
    required this.onClose,
  });

  final AlertMapItem alert;
  final bool isMyReport;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  IconData _alertIcon(AlertType type) {
    return switch (type) {
      AlertType.stockBajo => Icons.inventory_2_rounded,
      AlertType.sobreprecio => Icons.trending_up_rounded,
      AlertType.bloqueo => Icons.block_rounded,
      AlertType.retrasoProveedor => Icons.local_shipping_rounded,
      AlertType.combustible => Icons.local_gas_station_rounded,
      AlertType.productoNoDisponible => Icons.store_mall_directory_rounded,
      AlertType.celebracion => Icons.celebration_rounded,
      AlertType.fiesta => Icons.festival_rounded,
      AlertType.eventoComunitario => Icons.groups_rounded,
      AlertType.conciertoLibre => Icons.music_note_rounded,
      AlertType.feria => Icons.storefront_rounded,
      AlertType.entradaFolklorica => Icons.accessibility_new_rounded,
      AlertType.descuento => Icons.local_offer_rounded,
      AlertType.promocion => Icons.campaign_rounded,
      AlertType.marcha => Icons.directions_walk_rounded,
      AlertType.transporte => Icons.directions_bus_rounded,
      AlertType.abastecimiento => Icons.shopping_cart_rounded,
      AlertType.seguridad => Icons.security_rounded,
      AlertType.cultura => Icons.palette_rounded,
      AlertType.deporte => Icons.sports_soccer_rounded,
      AlertType.salud => Icons.health_and_safety_rounded,
      AlertType.emergencia => Icons.warning_rounded,
      AlertType.servicioPublico => Icons.account_balance_rounded,
      AlertType.otro => Icons.report_problem_rounded,
    };
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} - $hour:$minute';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar reporte'),
        content: const Text('Estas seguro de eliminar este evento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final severity = severityColor(alert.severity);
    final locationParts = [
      alert.zone,
      alert.municipality,
      alert.department,
    ].where((value) => value != null && value.trim().isNotEmpty).cast<String>();
    final location = locationParts.isEmpty
        ? 'Bolivia'
        : locationParts.join(' - ');
    final summaryParts = [
      if (alert.product != null && alert.product!.trim().isNotEmpty)
        alert.product!.trim(),
      alert.alertType.label,
      alert.severity.label,
    ];
    final confidenceLabel = '${(alert.confidence * 100).round()}% de confianza';
    final reportsLabel = alert.reportsCount == 1
        ? '1 reporte relacionado'
        : '${alert.reportsCount} reportes relacionados';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 13, 10, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: severity.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _alertIcon(alert.alertType),
                      color: severity,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMyReport)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF2563EB,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Tu evento',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        Text(
                          alert.title,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            height: 1.14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final value in summaryParts)
                              _AlertInfoChip(
                                label: value,
                                color: value == alert.severity.label
                                    ? severity
                                    : const Color(0xFF475569),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      if (isMyReport) ...[
                        const SizedBox(height: 4),
                        FilledButton.tonal(
                          onPressed: () => _confirmDelete(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFEE2E2),
                            foregroundColor: const Color(0xFFDC2626),
                            minimumSize: const Size(52, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (alert.description != null &&
                  alert.description!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    alert.description!.trim(),
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _AlertDetailRow(
                icon: Icons.location_on_outlined,
                label: location,
              ),
              const SizedBox(height: 8),
              _AlertDetailRow(
                icon: Icons.analytics_outlined,
                label: '$confidenceLabel - $reportsLabel',
              ),
              if (alert.avgPrice != null) ...[
                const SizedBox(height: 8),
                _AlertDetailRow(
                  icon: Icons.payments_outlined,
                  label:
                      'Precio referencial Bs ${alert.avgPrice!.toStringAsFixed(2)}',
                ),
              ],
              const SizedBox(height: 8),
              _AlertDetailRow(
                icon: Icons.schedule_rounded,
                label: 'Actualizado ${_formatDate(alert.lastReportedAt)}',
              ),
              if (alert.images.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: alert.images.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final image = alert.images[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          image,
                          width: 96,
                          height: 84,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 96,
                            height: 84,
                            color: const Color(0xFFE2E8F0),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertInfoChip extends StatelessWidget {
  const _AlertInfoChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AlertDetailRow extends StatelessWidget {
  const _AlertDetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12.5,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
  // AnÃ¡lisis IA (Paso 1) + formulario dinÃ¡mico (Paso 2).
  AnalyzedReport? _analyzed;
  String _category = 'otro';
  String _categoryLabel = 'Otro';
  String _riskLevel = 'info';
  String _summary = '';
  List<AnalyzedField> _optionalFields = const [];
  final Map<String, TextEditingController> _dynCtrls = {};
  final Map<String, String?> _dynValues = {};
  bool _isParsing = false;
  bool _isPublishing = false;
  bool _isListening = false;
  bool _isMapSdkLoading = kIsWeb && AppConfig.googleMapsApiKey.isNotEmpty;
  bool _showPreview = false;
  bool _optionalFieldsOpen = false;
  String? _error;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadGoogleMapsSdk();
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
    for (final c in _dynCtrls.values) {
      c.dispose();
    }
    _speech.stop();
    super.dispose();
  }

  void _setOptionalFields(List<AnalyzedField> fields) {
    for (final c in _dynCtrls.values) {
      c.dispose();
    }
    _dynCtrls.clear();
    _dynValues.clear();
    _optionalFields = fields;
    for (final f in fields) {
      if (f.type == 'select' || f.type == 'bool') {
        _dynValues[f.key] = f.value;
      } else {
        _dynCtrls[f.key] = TextEditingController(text: f.value ?? '');
      }
    }
  }

  void _selectCategory(String value) {
    final config = optionalConfigForCategory(value);
    setState(() {
      _category = value;
      _categoryLabel = config.label;
      _riskLevel = config.riskLevel;
      _alertType = _alertTypeForCategory(value);
      _severity = _severityForRisk(config.riskLevel);
      _setOptionalFields(
        optionalFieldsForCategory(category: value, analyzed: _analyzed),
      );
    });
  }

  AlertType _alertTypeForCategory(String c) {
    switch (c) {
      case 'bloqueo':
      case 'marcha':
        return AlertType.bloqueo;
      case 'combustible':
        return AlertType.combustible;
      case 'abastecimiento':
        return AlertType.productoNoDisponible;
      default:
        return AlertType.otro;
    }
  }

  AlertSeverity _severityForRisk(String r) {
    switch (r) {
      case 'low':
        return AlertSeverity.low;
      case 'medium':
        return AlertSeverity.medium;
      case 'high':
      case 'critical':
        return AlertSeverity.high;
      default:
        return AlertSeverity.normal;
    }
  }

  Map<String, String> _collectDynamicValues() {
    final out = <String, String>{};
    for (final f in _analyzed?.fields ?? const []) {
      final raw = (f.type == 'select' || f.type == 'bool')
          ? _dynValues[f.key]
          : _dynCtrls[f.key]?.text.trim();
      if (raw != null && raw.isNotEmpty) out[f.key] = raw;
    }
    return out;
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
      _mapController?.animateCamera(CameraUpdate.newLatLng(location));
    });
  }

  void _onLocationMapCreated(GoogleMapController controller) {
    _mapController = controller;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_location, 13));
  }

  Widget _buildLocationMap() {
    final missingKey = kIsWeb && AppConfig.googleMapsApiKey.isEmpty;

    if (missingKey) {
      return const _MapStateMessage(
        icon: Icons.key_off_rounded,
        title: 'Configura Google Maps',
        message: 'No se puede seleccionar el punto sin API key.',
      );
    }

    if (_isMapSdkLoading) {
      return const _MapStateMessage(
        icon: Icons.map_rounded,
        title: 'Cargando mapa',
        message: 'Preparando la vista de ubicacion.',
      );
    }

    return GoogleMap(
      key: const ValueKey('publish_location_map'),
      onMapCreated: _onLocationMapCreated,
      initialCameraPosition: CameraPosition(target: _location, zoom: 13),
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
      liteModeEnabled: false,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
    );
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

  String? _validateReportContent({
    required String source,
    required String title,
    required String description,
    bool hasImages = false,
  }) {
    if (hasImages) return null;

    final combined = '$source $title $description'.trim().toLowerCase();
    final letters = RegExp(r'[a-zÃ¡Ã©Ã­Ã³ÃºÃ±]').allMatches(combined).length;
    final cleaned = combined.replaceAll(
      RegExp(r'[^a-zÃ¡Ã©Ã­Ã³ÃºÃ±0-9\s]'),
      ' ',
    );
    final words = cleaned
        .split(RegExp(r'\s+'))
        .where((word) => word.length >= 2)
        .toList();
    final uniqueWords = words.toSet().length;
    final repeatedNoise = RegExp(
      r'(.)\1{5,}',
    ).hasMatch(combined.replaceAll(' ', ''));

    if (repeatedNoise || letters < 12 || words.length < 3 || uniqueWords < 2) {
      return 'El evento no parece tener informacion suficiente o coherente.';
    }

    return null;
  }

  Future<void> _parseReport() async {
    final text = _sourceController.text.trim();
    if (text.isEmpty && _images.isEmpty) {
      setState(() => _error = 'Escribe un reporte o sube una imagen');
      return;
    }
    final validationError = _validateReportContent(
      source: text,
      title: '',
      description: '',
      hasImages: _images.isNotEmpty,
    );
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _isParsing = true;
      _error = null;
    });

    try {
      final analyzed = await widget.reportsApi.analyzeReport(
        text: text,
        images: _images,
        latitude: _location.latitude,
        longitude: _location.longitude,
      );
      _setOptionalFields(
        optionalFieldsForCategory(
          category: analyzed.category,
          analyzed: analyzed,
        ),
      );
      setState(() {
        _analyzed = analyzed;
        _category = analyzed.category;
        _categoryLabel = analyzed.categoryLabel;
        _riskLevel = analyzed.riskLevel;
        _summary = analyzed.summary;
        _confidence = analyzed.confidence;
        _alertType = _alertTypeForCategory(analyzed.category);
        _severity = _severityForRisk(analyzed.riskLevel);
        _titleController.text = analyzed.title;
        _descriptionController.text = analyzed.description;
        _zoneController.text = analyzed.zone ?? '';
        _isParsing = false;
        _showPreview = true;
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
    final description = _descriptionController.text.trim();
    if (title.length < 3) {
      setState(() => _error = 'El titulo es obligatorio');
      return;
    }
    if (description.length < 3) {
      setState(() => _error = 'La descripcion es obligatoria');
      return;
    }
    if (_category.trim().isEmpty) {
      setState(() => _error = 'Selecciona una categoria');
      return;
    }
    final validationError = _validateReportContent(
      source: _sourceController.text.trim(),
      title: title,
      description: description,
    );
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    if (!isInsideBolivia(_location.latitude, _location.longitude)) {
      setState(() => _error = 'La ubicacion debe estar dentro de Bolivia');
      return;
    }

    final values = _collectDynamicValues();
    setState(() {
      _isPublishing = true;
      _error = null;
    });

    final categoryConfig = optionalConfigForCategory(_category);
    final details = <String, dynamic>{
      'category': _category,
      'categoryLabel': _categoryLabel,
      'group': _analyzed?.group ?? categoryConfig.group,
      'icon': _analyzed?.icon ?? categoryConfig.icon,
      'color': _analyzed?.color ?? categoryConfig.color,
      'riskLevel': _riskLevel,
      'summary': _summary,
      'values': values,
    };

    try {
      final product = _productController.text.trim();
      final id = await widget.reportsApi.publishReport(
        PublishReportInput(
          title: title,
          description: description,
          product: product.isEmpty ? null : product,
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
          category: _category,
          details: details,
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                if (_showPreview)
                  IconButton(
                    onPressed: () => setState(() => _showPreview = false),
                    icon: const Icon(Icons.arrow_back_rounded),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                  ),
                Expanded(
                  child: Text(
                    _showPreview ? 'Confirmar evento' : 'Subir evento',
                    style: const TextStyle(
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
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showPreview ? _buildPreview() : _buildInputForm(),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + safeBottom),
            child: _showPreview
                ? FilledButton.icon(
                    onPressed: _isPublishing ? null : _publish,
                    icon: _isPublishing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.publish_rounded),
                    label: const Text('Publicar evento'),
                  )
                : FilledButton.icon(
                    onPressed: _isParsing ? null : _parseReport,
                    icon: _isParsing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _images.isNotEmpty
                                ? Icons.image_search_rounded
                                : Icons.auto_awesome_rounded,
                          ),
                    label: Text(
                      _images.isNotEmpty
                          ? 'Analizar con IA Visual'
                          : 'Analizar texto',
                    ),
                  ),
          ),
          if (bottomInset > 0) SizedBox(height: bottomInset),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Column(
      key: const ValueKey('input_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Paso 1 de 2',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Describe el evento o sube fotos. En el siguiente paso podrÃ¡s revisar y confirmar los datos antes de publicar.',
                style: TextStyle(color: Color(0xFF475569), fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _sourceController,
          minLines: 4,
          maxLines: 7,
          decoration: const InputDecoration(
            labelText: 'DescripciÃ³n del evento',
            hintText: 'En el mercado Rodriguez el azÃºcar subiÃ³ a 9 Bs...',
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _toggleVoice,
          icon: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded),
          label: Text(_isListening ? 'Detener dictado' : 'Dictar con voz'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
        const SizedBox(height: 16),
        _SheetSection(
          title: 'UbicaciÃ³n',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildLocationMap(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lat ${_location.latitude.toStringAsFixed(5)}, Lng ${_location.longitude.toStringAsFixed(5)}',
                style: TextStyle(
                  color:
                      isInsideBolivia(_location.latitude, _location.longitude)
                      ? const Color(0xFF64748B)
                      : const Color(0xFFEF4444),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _requestLocation,
                icon: const Icon(Icons.my_location_rounded),
                label: const Text('Usar ubicaciÃ³n actual'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SheetSection(
          title: 'ImÃ¡genes',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Agrega hasta 3 fotos para que la IA entienda mejor la situaciÃ³n.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _images.length >= 3 ? null : _pickImages,
                icon: const Icon(Icons.add_photo_alternate_rounded),
                label: const Text('Agregar imÃ¡genes'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
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
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      key: const ValueKey('preview_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Paso 2 de 2: Confirmar evento',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_images.isNotEmpty) ...[
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) =>
                        _ImagePreview(image: _images[index], onRemove: () {}),
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemCount: _images.length,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                initialValue: kReportCategories.any((c) => c.code == _category)
                    ? _category
                    : 'otro',
                decoration: const InputDecoration(labelText: 'CategorÃ­a'),
                items: kReportCategories
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.code, child: Text(c.label)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  _selectCategory(value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'TÃ­tulo o nombre del evento',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'DescripciÃ³n'),
              ),
              if (_analyzed?.usedAi ?? false) ...[
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Detectado por IA',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: EdgeInsets.zero,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: _optionalFieldsOpen,
              onExpansionChanged: (value) =>
                  setState(() => _optionalFieldsOpen = value),
              tilePadding: const EdgeInsets.symmetric(horizontal: 14),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              title: const Text(
                'Agregar datos opcionales',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              children: [
                DynamicOptionalFieldsWidget(
                  fields: _optionalFields,
                  controllers: _dynCtrls,
                  values: _dynValues,
                  onValueChanged: (key, value) =>
                      setState(() => _dynValues[key] = value),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'UbicaciÃ³n textual',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _departmentController,
                  decoration: const InputDecoration(labelText: 'Departamento'),
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
      ],
    );
  }
}

class _RouteBanner extends StatelessWidget {
  const _RouteBanner({
    required this.isLoading,
    required this.route,
    required this.error,
    required this.onClose,
  });

  final bool isLoading;
  final RouteResult? route;
  final String? error;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final List<Widget> content;
    if (isLoading) {
      content = const [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Calculando la mejor rutaâ€¦',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ];
    } else if (error != null) {
      content = [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            error!,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ];
    } else {
      final r = route!;
      content = [
        Icon(
          r.avoidedBlockades
              ? Icons.alt_route_rounded
              : Icons.warning_amber_rounded,
          color: r.avoidedBlockades
              ? const Color(0xFF2563EB)
              : const Color(0xFFEF4444),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${r.distanceText} Â· ${r.durationText}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                r.avoidedBlockades
                    ? 'Ruta libre de bloqueos'
                    : 'AtenciÃ³n: pasa por ${r.blockadesOnRoute} obstrucciÃ³n(es)',
                style: TextStyle(
                  color: r.avoidedBlockades
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFEF4444),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ...content,
            IconButton(
              tooltip: 'Quitar ruta',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: [
                  const BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: snapshot.hasData
                    ? Image.memory(
                        snapshot.data!,
                        width: 116,
                        height: 116,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 116,
                        height: 116,
                        color: const Color(0xFFF8FAFC),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton.filledTonal(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 16),
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 0, 0, 0.6),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
