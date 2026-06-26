import 'package:mapiafrontend/core/utils/distance_utils.dart';
import 'package:mapiafrontend/features/alerts/data/models/nearby_alert_group_model.dart';
import 'package:mapiafrontend/features/location/domain/entities/location_entity.dart';
import 'package:mapiafrontend/features/posts/data/datasources/mock_posts_datasource.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class AlertsMockDatasource {
  const AlertsMockDatasource({
    this.postsDatasource = const MockPostsDatasource(),
  });

  final MockPostsDatasource postsDatasource;

  Future<List<NearbyAlertGroupModel>> getNearbyAlertGroups({
    required AppLocationEntity location,
    required double radiusKm,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final posts = _nearbyPosts(location: location, radiusKm: radiusKm);
    final groups = <NearbyAlertGroupModel>[];

    for (final type in _orderedTypes) {
      final count = posts.where((post) => post.type == type).length;
      if (count == 0) continue;
      groups.add(
        NearbyAlertGroupModel.fromPosts(
          type: type,
          count: count,
          radiusKm: radiusKm,
        ),
      );
    }

    return groups;
  }

  Future<List<PostEntity>> getNearbyPostsByType({
    required PostType type,
    required AppLocationEntity location,
    required double radiusKm,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _nearbyPosts(
      location: location,
      radiusKm: radiusKm,
    ).where((post) => post.type == type).toList();
  }

  List<PostEntity> _nearbyPosts({
    required AppLocationEntity location,
    required double radiusKm,
  }) {
    return postsDatasource.getPosts().where((post) {
      final distance = calculateDistanceKm(
        lat1: location.latitude,
        lon1: location.longitude,
        lat2: post.latitude,
        lon2: post.longitude,
      );
      return distance <= radiusKm;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static const _orderedTypes = [
    PostType.blockade,
    PostType.foodDeal,
    PostType.party,
    PostType.serviceCut,
    PostType.sale,
    PostType.novelty,
    PostType.accident,
    PostType.traffic,
    PostType.security,
    PostType.news,
    PostType.lostFound,
    PostType.other,
  ];
}
