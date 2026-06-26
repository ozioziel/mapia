import 'package:flutter/material.dart';
import 'package:mapiafrontend/features/location/domain/entities/location_entity.dart';
import 'package:mapiafrontend/features/map/presentation/widgets/map_view/mock_map_view.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class GoogleMapView extends StatelessWidget {
  const GoogleMapView({
    super.key,
    required this.posts,
    required this.selectedPost,
    required this.userLocation,
    required this.onPostTap,
    required this.onMapTap,
    required this.onMyLocationTap,
  });

  final List<PostEntity> posts;
  final PostEntity? selectedPost;
  final AppLocationEntity? userLocation;
  final ValueChanged<PostEntity> onPostTap;
  final VoidCallback onMapTap;
  final VoidCallback onMyLocationTap;

  @override
  Widget build(BuildContext context) {
    // Future integration point:
    // return GoogleMap(
    //   initialCameraPosition: CameraPosition(
    //     target: LatLng(userLocation.latitude, userLocation.longitude),
    //     zoom: 14,
    //   ),
    //   markers: posts.map(...).toSet(),
    //   onTap: (_) => onMapTap(),
    // );
    return MockMapView(
      posts: posts,
      selectedPost: selectedPost,
      userLocation: userLocation,
      onPostTap: onPostTap,
      onMapTap: onMapTap,
      onMyLocationTap: onMyLocationTap,
    );
  }
}
