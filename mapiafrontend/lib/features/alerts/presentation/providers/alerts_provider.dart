import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/alerts/data/datasources/alerts_mock_datasource.dart';
import 'package:mapiafrontend/features/alerts/data/repositories/alerts_repository_impl.dart';
import 'package:mapiafrontend/features/alerts/domain/entities/nearby_alert_group_entity.dart';
import 'package:mapiafrontend/features/alerts/domain/usecases/get_nearby_alert_groups_usecase.dart';
import 'package:mapiafrontend/features/alerts/domain/usecases/get_nearby_posts_by_type_usecase.dart';
import 'package:mapiafrontend/features/location/domain/entities/location_entity.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class AlertsProvider extends ChangeNotifier {
  AlertsProvider({
    GetNearbyAlertGroupsUsecase? getGroupsUsecase,
    GetNearbyPostsByTypeUsecase? getPostsByTypeUsecase,
  }) : _getGroupsUsecase = getGroupsUsecase ?? _defaultGetGroupsUsecase,
       _getPostsByTypeUsecase =
           getPostsByTypeUsecase ?? _defaultGetPostsByTypeUsecase;

  static const userMockLocation = AppLocationEntity(
    latitude: -16.5000,
    longitude: -68.1500,
    address: 'La Paz, Bolivia / Sopocachi / Zona actual mock',
  );

  static final _repository = AlertsRepositoryImpl(const AlertsMockDatasource());
  static final _defaultGetGroupsUsecase = GetNearbyAlertGroupsUsecase(
    _repository,
  );
  static final _defaultGetPostsByTypeUsecase = GetNearbyPostsByTypeUsecase(
    _repository,
  );

  final GetNearbyAlertGroupsUsecase _getGroupsUsecase;
  final GetNearbyPostsByTypeUsecase _getPostsByTypeUsecase;

  final List<double> radiusOptionsKm = const [1, 3, 5, 10];
  double selectedRadiusKm = 3;
  List<NearbyAlertGroupEntity> groups = [];
  List<PostEntity> nearbyPosts = [];
  bool isLoading = false;
  String? error;

  AppLocationEntity get currentLocation => userMockLocation;

  Future<void> loadGroups() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      groups = await _getGroupsUsecase(
        location: currentLocation,
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

    try {
      nearbyPosts = await _getPostsByTypeUsecase(
        type: type,
        location: currentLocation,
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
