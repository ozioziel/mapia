import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapiafrontend/features/alerts/data/datasources/alerts_remote_datasource.dart';
import 'package:mapiafrontend/features/alerts/data/repositories/alerts_repository_impl.dart';
import 'package:mapiafrontend/features/alerts/domain/entities/nearby_alert_group_entity.dart';
import 'package:mapiafrontend/features/alerts/domain/usecases/get_nearby_alert_groups_usecase.dart';
import 'package:mapiafrontend/features/alerts/domain/usecases/get_nearby_posts_by_type_usecase.dart';
import 'package:mapiafrontend/features/location/domain/entities/location_entity.dart';
import 'package:mapiafrontend/features/map/services/map_api.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class AlertsProvider extends ChangeNotifier {
  AlertsProvider({required MapApi mapApi})
    : _getGroupsUsecase = GetNearbyAlertGroupsUsecase(
        AlertsRepositoryImpl(AlertsRemoteDatasource(mapApi: mapApi)),
      ),
      _getPostsByTypeUsecase = GetNearbyPostsByTypeUsecase(
        AlertsRepositoryImpl(AlertsRemoteDatasource(mapApi: mapApi)),
      );

  final GetNearbyAlertGroupsUsecase _getGroupsUsecase;
  final GetNearbyPostsByTypeUsecase _getPostsByTypeUsecase;

  final List<double> radiusOptionsKm = const [1, 3, 5, 10];
  double selectedRadiusKm = 3;
  List<NearbyAlertGroupEntity> groups = [];
  List<PostEntity> nearbyPosts = [];
  bool isLoading = false;
  String? error;

  AppLocationEntity? _location;
  AppLocationEntity get currentLocation =>
      _location ??
      const AppLocationEntity(
        latitude: 0,
        longitude: 0,
        address: 'Tu ubicación',
      );

  /// Resuelve la ubicación real del dispositivo (sin datos mock).
  Future<AppLocationEntity?> _resolveLocation() async {
    if (_location != null) return _location;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final pos =
          await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition();
      _location = AppLocationEntity(
        latitude: pos.latitude,
        longitude: pos.longitude,
        address: 'Tu ubicación',
      );
      return _location;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadGroups() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final location = await _resolveLocation();
    if (location == null) {
      error = 'Activa tu ubicación para ver alertas cercanas.';
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      groups = await _getGroupsUsecase(
        location: location,
        radiusKm: selectedRadiusKm,
      );
    } catch (_) {
      error = 'No pudimos cargar las alertas cercanas.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectRadius(double radiusKm) async {
    if (selectedRadiusKm == radiusKm) return;
    selectedRadiusKm = radiusKm;
    await loadGroups();
  }

  Future<void> loadPostsByType(PostType type, double radiusKm) async {
    isLoading = true;
    error = null;
    nearbyPosts = [];
    notifyListeners();

    final location = await _resolveLocation();
    if (location == null) {
      error = 'Activa tu ubicación para ver publicaciones cercanas.';
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      nearbyPosts = await _getPostsByTypeUsecase(
        type: type,
        location: location,
        radiusKm: radiusKm,
      );
    } catch (_) {
      error = 'No pudimos cargar las publicaciones cercanas.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
