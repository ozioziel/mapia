import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapiafrontend/features/map/utils/bolivia_bounds.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class PostMapMarkerIcons {
  PostMapMarkerIcons._(this._icons);

  final Map<PostType, BitmapDescriptor> _icons;

  BitmapDescriptor iconFor(PostType type) {
    return _icons[type] ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }

  static Future<PostMapMarkerIcons> create() async {
    final entries = await Future.wait(
      PostType.values.map((type) async {
        return MapEntry(type, await _createIcon(type));
      }),
    );
    return PostMapMarkerIcons._(Map.fromEntries(entries));
  }

  static Future<BitmapDescriptor> _createIcon(PostType type) async {
    const double size = 104;
    const double center = size / 2;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final option = type.option;

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10);
    canvas.drawCircle(const Offset(center, center + 5), 36, shadow);

    canvas.drawCircle(
      const Offset(center, center),
      37,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      const Offset(center, center),
      29,
      Paint()..color = option.color,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(option.icon.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontFamily: option.icon.fontFamily,
          package: option.icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center - textPainter.width / 2, center - textPainter.height / 2),
    );

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final data = bytes?.buffer.asUint8List() ?? Uint8List(0);
    return BitmapDescriptor.bytes(data, width: 54, height: 54);
  }
}

Set<Marker> renderExplorePostMarkers({
  required List<PostEntity> posts,
  required Set<PostType> enabledTypes,
  required PostMapMarkerIcons? markerIcons,
  required ValueChanged<PostEntity> onTap,
}) {
  return {
    for (final post in posts)
      if (isInsideBolivia(post.latitude, post.longitude) &&
          enabledTypes.contains(post.type))
        Marker(
          markerId: MarkerId('explore_post_${post.id}'),
          position: LatLng(post.latitude, post.longitude),
          icon:
              markerIcons?.iconFor(post.type) ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: post.title,
            snippet: '${post.type.option.label} - ${post.authorName}',
          ),
          onTap: () => onTap(post),
        ),
  };
}
