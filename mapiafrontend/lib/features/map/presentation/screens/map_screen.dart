import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/posts/data/datasources/mock_posts_datasource.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<PostEntity> _posts = const MockPostsDatasource().getPosts();
  PostEntity? _selectedPost;
  int _currentIndex = 0;
  bool _layersEnabled = false;
  bool _centered = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1200),
        ),
      );
  }

  void _openPost(PostEntity post) {
    setState(() => _selectedPost = post);
  }

  void _closePost() {
    if (_selectedPost != null) {
      setState(() => _selectedPost = null);
    }
  }

  void _handleNavTap(int index) {
    if (index == 2) {
      Navigator.of(context).pushNamed('/create-post');
      return;
    }
    if (index == 4) {
      Navigator.of(context).pushNamed('/profile');
      return;
    }
    setState(() => _currentIndex = index);
    if (index != 0) {
      _showMessage('Sección lista para conectar');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closePost,
              child: const _LaPazMockMap(),
            ),
          ),
          if (_layersEnabled) const Positioned.fill(child: _RiskLayer()),
          Positioned.fill(
            child: _MapPostsOverlay(
              posts: _posts,
              selectedPost: _selectedPost,
              onPostTap: _openPost,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned(
                  left: compact ? 12 : 18,
                  right: compact ? 12 : 18,
                  top: compact ? 8 : 12,
                  child: _MapiaHeader(
                    onSearchTap: () => _showMessage('Buscar en Mapia'),
                    onMicTap: () => _showMessage('Búsqueda por voz'),
                    onProfileTap: () => _handleNavTap(4),
                  ),
                ),
                Positioned(
                  right: compact ? 12 : 16,
                  top: size.height * (compact ? 0.30 : 0.26),
                  child: _FloatingMapControls(
                    layersEnabled: _layersEnabled,
                    centered: _centered,
                    onLayersTap: () {
                      setState(() => _layersEnabled = !_layersEnabled);
                      _showMessage(
                        _layersEnabled ? 'Capas activadas' : 'Capas ocultas',
                      );
                    },
                    onCenterTap: () {
                      setState(() => _centered = !_centered);
                      _showMessage('Centrado en tu ubicación');
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_selectedPost != null)
            _SocialPostSheet(
              post: _selectedPost!,
              onClose: _closePost,
              onDetailTap: () => Navigator.of(
                context,
              ).pushNamed('/posts/${_selectedPost!.id}'),
              onLikeTap: () => _showMessage('Me gusta listo para conectar'),
              onCommentsTap: () => Navigator.of(
                context,
              ).pushNamed('/posts/${_selectedPost!.id}'),
              onShareTap: () => _showMessage('Compartir publicación'),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _MapiaBottomNavigation(
              currentIndex: _currentIndex,
              onIndexChanged: _handleNavTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapiaHeader extends StatelessWidget {
  const _MapiaHeader({
    required this.onSearchTap,
    required this.onMicTap,
    required this.onProfileTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onMicTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 10, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const _MapiaMark(),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mapia',
                      style: TextStyle(
                        color: AppTheme.textNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF0B8063),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'La Paz',
                          style: TextStyle(
                            color: AppTheme.mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onProfileTap,
                icon: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE7F7EF),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF0B8063),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                height: 46,
                padding: const EdgeInsets.only(left: 13, right: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FA),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8EF)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF65758A),
                      size: 21,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Buscar lugares, sucesos o novedades...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF65758A),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onMicTap,
                      icon: const Icon(
                        Icons.mic_none_rounded,
                        color: Color(0xFF4B5565),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapiaMark extends StatelessWidget {
  const _MapiaMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE53935), Color(0xFFFFC107), Color(0xFF0B9E59)],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(
          Icons.place_rounded,
          color: Color(0xFFE53935),
          size: 24,
        ),
      ),
    );
  }
}

class _FloatingMapControls extends StatelessWidget {
  const _FloatingMapControls({
    required this.layersEnabled,
    required this.centered,
    required this.onLayersTap,
    required this.onCenterTap,
  });

  final bool layersEnabled;
  final bool centered;
  final VoidCallback onLayersTap;
  final VoidCallback onCenterTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MapControlButton(
          icon: Icons.layers_outlined,
          active: layersEnabled,
          onTap: onLayersTap,
        ),
        const SizedBox(height: 12),
        _MapControlButton(
          icon: Icons.my_location_rounded,
          active: centered,
          onTap: onCenterTap,
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE1F5FE) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: active ? AppTheme.primaryBlue : const Color(0xFF3C4043),
            size: 24,
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
    final softYellow = Paint()..color = const Color(0xFFFFF4D8);
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
    final street = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final streetBorder = Paint()
      ..color = const Color(0xFFDDE5EA)
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.24)
        ..cubicTo(
          size.width * 0.12,
          size.height * 0.18,
          size.width * 0.20,
          size.height * 0.34,
          size.width * 0.33,
          size.height * 0.30,
        )
        ..lineTo(0, size.height * 0.57)
        ..close(),
      hillPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height * 0.28)
        ..cubicTo(
          size.width * 0.83,
          size.height * 0.34,
          size.width * 0.80,
          size.height * 0.49,
          size.width * 0.64,
          size.height * 0.54,
        )
        ..lineTo(size.width, size.height * 0.70)
        ..close(),
      hillPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.70, size.width * 0.42, size.height),
      softYellow,
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
      _path(size, const Offset(0.03, 0.82), const Offset(0.95, 0.39)),
      _path(size, const Offset(0.45, 0.16), const Offset(0.34, 0.82)),
      _path(size, const Offset(0.18, 0.54), const Offset(0.85, 0.24)),
      _path(size, const Offset(0.66, 0.12), const Offset(0.83, 0.78)),
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

  Path _path(Size size, Offset a, Offset b) {
    return Path()
      ..moveTo(size.width * a.dx, size.height * a.dy)
      ..lineTo(size.width * b.dx, size.height * b.dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RiskLayer extends StatelessWidget {
  const _RiskLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _RiskLayerPainter()));
  }
}

class _RiskLayerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final red = Paint()
      ..color = const Color(0xFFE53935).withValues(alpha: 0.12);
    final yellow = Paint()
      ..color = const Color(0xFFFFC107).withValues(alpha: 0.16);
    final green = Paint()
      ..color = const Color(0xFF0B9E59).withValues(alpha: 0.10);

    canvas.drawCircle(
      Offset(size.width * 0.44, size.height * 0.39),
      size.width * 0.23,
      red,
    );
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.78),
      size.width * 0.26,
      yellow,
    );
    canvas.drawCircle(
      Offset(size.width * 0.74, size.height * 0.49),
      size.width * 0.20,
      green,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPostsOverlay extends StatelessWidget {
  const _MapPostsOverlay({
    required this.posts,
    required this.selectedPost,
    required this.onPostTap,
  });

  final List<PostEntity> posts;
  final PostEntity? selectedPost;
  final ValueChanged<PostEntity> onPostTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: [
            IgnorePointer(
              child: Stack(
                children: [
                  _MapLabel(
                    text: 'Av. Busch',
                    left: width * 0.36,
                    top: height * 0.44,
                    rotation: -1.45,
                  ),
                  _MapLabel(
                    text: 'Av. Saavedra',
                    left: width * 0.48,
                    top: height * 0.22,
                    rotation: -0.78,
                  ),
                  _MapLabel(
                    text: 'Sopocachi',
                    left: width * 0.13,
                    top: height * 0.61,
                    color: AppTheme.primaryBlue,
                    fontSize: 18,
                  ),
                  _MapLabel(
                    text: 'Villa Fátima',
                    left: width * 0.66,
                    top: height * 0.34,
                    color: const Color(0xFF0B8063),
                    fontSize: 16,
                  ),
                  Positioned(
                    left: width * 0.51,
                    top: height * 0.62,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < posts.length; i++)
              _PostMarker(
                post: posts[i],
                selected: selectedPost?.id == posts[i].id,
                left: width * _markerPosition(i).dx,
                top: height * _markerPosition(i).dy,
                onTap: () => onPostTap(posts[i]),
              ),
          ],
        );
      },
    );
  }

  Offset _markerPosition(int index) {
    const positions = [
      Offset(0.27, 0.52),
      Offset(0.18, 0.68),
      Offset(0.44, 0.36),
      Offset(0.64, 0.48),
      Offset(0.76, 0.42),
      Offset(0.53, 0.59),
      Offset(0.34, 0.44),
    ];
    return positions[index % positions.length];
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel({
    required this.text,
    required this.left,
    required this.top,
    this.rotation = 0,
    this.color = const Color(0xFF46515F),
    this.fontSize = 15,
  });

  final String text;
  final double left;
  final double top;
  final double rotation;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: rotation,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
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

class _PostMarker extends StatelessWidget {
  const _PostMarker({
    required this.post,
    required this.selected,
    required this.left,
    required this.top,
    required this.onTap,
  });

  final PostEntity post;
  final bool selected;
  final double left;
  final double top;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final option = post.type.option;
    final initial = post.authorName.trim().isEmpty
        ? '?'
        : post.authorName.trim().characters.first.toUpperCase();

    return Positioned(
      left: left,
      top: top,
      child: Semantics(
        button: true,
        label: 'Publicación de ${post.authorName}',
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedScale(
            scale: selected ? 1.14 : 1,
            duration: const Duration(milliseconds: 180),
            child: SizedBox(
              width: 58,
              height: 64,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? option.color : Colors.white,
                        width: selected ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: option.color,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 30,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: option.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(option.icon, color: Colors.white, size: 13),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    child: Container(
                      width: 3,
                      height: 10,
                      decoration: BoxDecoration(
                        color: option.color,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialPostSheet extends StatelessWidget {
  const _SocialPostSheet({
    required this.post,
    required this.onClose,
    required this.onDetailTap,
    required this.onLikeTap,
    required this.onCommentsTap,
    required this.onShareTap,
  });

  final PostEntity post;
  final VoidCallback onClose;
  final VoidCallback onDetailTap;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentsTap;
  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 720;

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent <= 0.13) {
          Future.microtask(onClose);
        }
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: compact ? 0.38 : 0.36,
        minChildSize: 0.10,
        maxChildSize: compact ? 0.66 : 0.58,
        snap: true,
        snapSizes: compact
            ? const [0.10, 0.38, 0.66]
            : const [0.10, 0.36, 0.58],
        builder: (context, scrollController) {
          final option = post.type.option;

          return SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.only(bottom: 76),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, -7),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4D9DF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundColor: option.color.withValues(alpha: 0.12),
                        child: Icon(option.icon, color: option.color, size: 24),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textNavy,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_timeAgo(post.createdAt)} · ${post.address ?? 'La Paz'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.mutedText,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusBadge(isVerified: post.isVerified),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [_TypeBadge(option: option)],
                  ),
                  const SizedBox(height: 13),
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textNavy,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    post.description,
                    style: const TextStyle(
                      color: Color(0xFF4F5B6B),
                      fontSize: 14.5,
                      height: 1.34,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (post.mediaUrl != null) ...[
                    const SizedBox(height: 14),
                    _MockPostImage(option: option),
                  ],
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  _SocialActions(
                    likesCount: post.likesCount,
                    commentsCount: post.commentsCount,
                    isLiked: post.isLiked,
                    onLikeTap: onLikeTap,
                    onCommentsTap: onCommentsTap,
                    onShareTap: onShareTap,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onDetailTap,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Ver detalle'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} d';
  }
}

class _MockPostImage extends StatelessWidget {
  const _MockPostImage({required this.option});

  final PostTypeOption option;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                option.color.withValues(alpha: 0.78),
                const Color(0xFFFFC107).withValues(alpha: 0.62),
                const Color(0xFF0B9E59).withValues(alpha: 0.70),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -24,
                child: Icon(
                  option.icon,
                  size: 116,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final color = isVerified
        ? const Color(0xFF0B8063)
        : const Color(0xFFFFA000);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isVerified ? 'Verificado' : 'En revisión',
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.option});

  final PostTypeOption option;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: option.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(option.icon, color: option.color, size: 15),
          const SizedBox(width: 5),
          Text(
            option.label,
            style: TextStyle(
              color: option.color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialActions extends StatelessWidget {
  const _SocialActions({
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.onLikeTap,
    required this.onCommentsTap,
    required this.onShareTap,
  });

  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentsTap;
  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _SocialActionButton(
          icon: isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          label: '$likesCount',
          color: isLiked ? const Color(0xFFE53935) : const Color(0xFF5F6B7A),
          onTap: onLikeTap,
        ),
        _SocialActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: '$commentsCount comentarios',
          color: const Color(0xFF5F6B7A),
          onTap: onCommentsTap,
        ),
        _SocialActionButton(
          icon: Icons.ios_share_rounded,
          label: 'Compartir',
          color: const Color(0xFF5F6B7A),
          onTap: onShareTap,
        ),
      ],
    );
  }
}

class _SocialActionButton extends StatelessWidget {
  const _SocialActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 19),
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _MapiaBottomNavigation extends StatelessWidget {
  const _MapiaBottomNavigation({
    required this.currentIndex,
    required this.onIndexChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData('Mapa', Icons.map_rounded, const Color(0xFFE53935)),
      _NavItemData(
        'Explorar',
        Icons.travel_explore_rounded,
        const Color(0xFFE53935),
      ),
      _NavItemData('Publicar', Icons.add_rounded, const Color(0xFFFFB300)),
      _NavItemData(
        'Alertas',
        Icons.notifications_none_rounded,
        const Color(0xFF0B8063),
      ),
      _NavItemData(
        'Perfil',
        Icons.person_outline_rounded,
        const Color(0xFF0B8063),
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
        padding: const EdgeInsets.fromLTRB(8, 5, 8, 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Expanded(child: _BoliviaStripe(color: Color(0xFFE53935))),
                Expanded(child: _BoliviaStripe(color: Color(0xFFFFC107))),
                Expanded(child: _BoliviaStripe(color: Color(0xFF0B9E59))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _BottomNavButton(
                      data: items[i],
                      active: currentIndex == i,
                      prominent: i == 2,
                      onTap: () => onIndexChanged(i),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BoliviaStripe extends StatelessWidget {
  const _BoliviaStripe({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(height: 3, color: color);
  }
}

class _NavItemData {
  const _NavItemData(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.data,
    required this.active,
    required this.prominent,
    required this.onTap,
  });

  final _NavItemData data;
  final bool active;
  final bool prominent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: EdgeInsets.fromLTRB(2, prominent ? 0 : 3, 2, 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prominent)
              Transform.translate(
                offset: const Offset(0, -10),
                child: const _PublishCircle(),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 42,
                height: 34,
                decoration: BoxDecoration(
                  color: active
                      ? data.color.withValues(alpha: 0.13)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  data.icon,
                  color: active ? data.color : const Color(0xFF5F6B7A),
                  size: 22,
                ),
              ),
            SizedBox(height: prominent ? 0 : 2),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? data.color : const Color(0xFF5F6B7A),
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublishCircle extends StatelessWidget {
  const _PublishCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC107), Color(0xFFFFA000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA000).withValues(alpha: 0.34),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
    );
  }
}
