import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/location/domain/entities/location_entity.dart';
import 'package:mapiafrontend/features/map/presentation/widgets/user_map_marker.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class MockMapView extends StatelessWidget {
  const MockMapView({
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onMapTap,
      child: Stack(
        children: [
          const Positioned.fill(child: _LaPazMockMap()),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);

                return Stack(
                  children: [
                    const _MapLabels(),
                    if (userLocation != null)
                      _UserLocationDot(position: _toMapOffset(userLocation!)),
                    for (final post in posts)
                      _PositionedPostMarker(
                        post: post,
                        selected: selectedPost?.id == post.id,
                        position: _toPostOffset(post),
                        canvasSize: size,
                        onPostTap: onPostTap,
                      ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            right: 14,
            bottom: 104,
            child: SafeArea(
              top: false,
              child: _MyLocationButton(onTap: onMyLocationTap),
            ),
          ),
        ],
      ),
    );
  }

  Offset _toPostOffset(PostEntity post) {
    return _latLngToOffset(post.latitude, post.longitude);
  }

  Offset _toMapOffset(AppLocationEntity location) {
    return _latLngToOffset(location.latitude, location.longitude);
  }

  Offset _latLngToOffset(double latitude, double longitude) {
    const minLat = -16.5165;
    const maxLat = -16.4945;
    const minLng = -68.1425;
    const maxLng = -68.1160;

    final x = ((longitude - minLng) / (maxLng - minLng)).clamp(0.08, 0.86);
    final y = ((maxLat - latitude) / (maxLat - minLat)).clamp(0.18, 0.78);

    return Offset(x.toDouble(), y.toDouble());
  }
}

class _PositionedPostMarker extends StatelessWidget {
  const _PositionedPostMarker({
    required this.post,
    required this.selected,
    required this.position,
    required this.canvasSize,
    required this.onPostTap,
  });

  final PostEntity post;
  final bool selected;
  final Offset position;
  final Size canvasSize;
  final ValueChanged<PostEntity> onPostTap;

  @override
  Widget build(BuildContext context) {
    const markerWidth = 58.0;
    const markerHeight = 64.0;
    final left = (canvasSize.width * position.dx - markerWidth / 2)
        .clamp(8.0, math.max(8.0, canvasSize.width - markerWidth - 8))
        .toDouble();
    final top = (canvasSize.height * position.dy - markerHeight / 2)
        .clamp(112.0, math.max(112.0, canvasSize.height - markerHeight - 132))
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      child: UserMapMarker(
        authorName: post.authorName,
        avatarUrl: post.authorAvatarUrl,
        type: post.type,
        selected: selected,
        onTap: () => onPostTap(post),
      ),
    );
  }
}

class _MyLocationButton extends StatelessWidget {
  const _MyLocationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.my_location_rounded,
                size: 20,
                color: AppTheme.primaryBlue,
              ),
              SizedBox(width: 7),
              Text(
                'Mi ubicación',
                style: TextStyle(
                  color: AppTheme.textNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot({required this.position});

  final Offset position;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Positioned(
          left: constraints.maxWidth * position.dx - 14,
          top: constraints.maxHeight * position.dy - 14,
          child: IgnorePointer(
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.24),
                    spreadRadius: 10,
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MapLabels extends StatelessWidget {
  const _MapLabels();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          _MapLabel(text: 'Sopocachi', left: 38, top: 430, fontSize: 18),
          _MapLabel(text: 'Miraflores', right: 34, top: 310, fontSize: 16),
          _MapLabel(text: 'El Prado', left: 122, top: 350),
          _MapLabel(text: 'Av. Busch', right: 86, top: 440, rotation: -0.55),
        ],
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel({
    required this.text,
    this.left,
    this.right,
    required this.top,
    this.rotation = 0,
    this.fontSize = 14,
  });

  final String text;
  final double? left;
  final double? right;
  final double top;
  final double rotation;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: Transform.rotate(
        angle: rotation,
        child: Text(
          text,
          style: TextStyle(
            color: const Color(0xFF46515F).withValues(alpha: 0.72),
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            shadows: const [
              Shadow(color: Colors.white, blurRadius: 4),
              Shadow(color: Colors.white, blurRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _LaPazMockMap extends StatelessWidget {
  const _LaPazMockMap();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LaPazMapPainter(),
      child: Container(color: const Color(0xFFF6F3EA)),
    );
  }
}

class _LaPazMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final hillPaint = Paint()..color = const Color(0xFFDCEFD5);
    final plazaPaint = Paint()..color = const Color(0xFFFFF4D8);
    final waterPaint = Paint()
      ..color = const Color(0xFFB7DFF5)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final roadShadow = Paint()
      ..color = const Color(0xFFD5DCE3)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final mainRoad = Paint()
      ..color = Colors.white
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final streetBorder = Paint()
      ..color = const Color(0xFFDDE5EA)
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final street = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.22)
        ..cubicTo(
          size.width * 0.16,
          size.height * 0.16,
          size.width * 0.24,
          size.height * 0.34,
          size.width * 0.36,
          size.height * 0.28,
        )
        ..lineTo(0, size.height * 0.58)
        ..close(),
      hillPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height * 0.26)
        ..cubicTo(
          size.width * 0.84,
          size.height * 0.33,
          size.width * 0.80,
          size.height * 0.50,
          size.width * 0.63,
          size.height * 0.55,
        )
        ..lineTo(size.width, size.height * 0.70)
        ..close(),
      hillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.07,
          size.height * 0.70,
          size.width * 0.34,
          size.height * 0.18,
        ),
        const Radius.circular(22),
      ),
      plazaPaint,
    );

    final river = Path()
      ..moveTo(size.width * 0.06, size.height * 0.18)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.30,
        size.width * 0.03,
        size.height * 0.42,
        size.width * 0.23,
        size.height * 0.56,
      )
      ..cubicTo(
        size.width * 0.39,
        size.height * 0.69,
        size.width * 0.24,
        size.height * 0.86,
        size.width * 0.42,
        size.height,
      );
    canvas.drawPath(river, waterPaint);

    final majorRoads = [
      _line(size, const Offset(0.03, 0.82), const Offset(0.95, 0.39)),
      _line(size, const Offset(0.45, 0.16), const Offset(0.34, 0.82)),
      _line(size, const Offset(0.18, 0.54), const Offset(0.85, 0.24)),
      _line(size, const Offset(0.66, 0.12), const Offset(0.83, 0.78)),
    ];

    for (final road in majorRoads) {
      canvas.drawPath(road, roadShadow);
      canvas.drawPath(road, mainRoad);
    }

    for (var i = -5; i < 14; i++) {
      final y = size.height * (0.18 + i * 0.055);
      final path = Path()
        ..moveTo(-20, y)
        ..lineTo(size.width + 20, y + size.height * 0.28);
      canvas.drawPath(path, streetBorder);
      canvas.drawPath(path, street);
    }

    for (var i = -2; i < 10; i++) {
      final x = size.width * (0.10 + i * 0.11);
      final path = Path()
        ..moveTo(x, size.height * 0.14)
        ..lineTo(x - size.width * 0.36, size.height * 0.95);
      canvas.drawPath(path, streetBorder);
      canvas.drawPath(path, street);
    }
  }

  Path _line(Size size, Offset a, Offset b) {
    return Path()
      ..moveTo(size.width * a.dx, size.height * a.dy)
      ..lineTo(size.width * b.dx, size.height * b.dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
