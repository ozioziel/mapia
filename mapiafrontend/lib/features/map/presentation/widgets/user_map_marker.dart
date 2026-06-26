import 'package:flutter/material.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class UserMapMarker extends StatelessWidget {
  const UserMapMarker({
    super.key,
    required this.authorName,
    required this.avatarUrl,
    required this.type,
    required this.onTap,
    this.selected = false,
  });

  final String authorName;
  final String? avatarUrl;
  final PostType type;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final option = type.option;
    final initial = authorName.trim().isEmpty
        ? '?'
        : authorName.trim().characters.first.toUpperCase();

    return Semantics(
      button: true,
      label: 'Publicación de $authorName',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.12 : 1,
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
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: _MarkerAvatar(
                        authorName: authorName,
                        avatarUrl: avatarUrl,
                        fallbackInitial: initial,
                        color: option.color,
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
                      boxShadow: [
                        BoxShadow(
                          color: option.color.withValues(alpha: 0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
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
    );
  }
}

class _MarkerAvatar extends StatelessWidget {
  const _MarkerAvatar({
    required this.authorName,
    required this.avatarUrl,
    required this.fallbackInitial,
    required this.color,
  });

  final String authorName;
  final String? avatarUrl;
  final String fallbackInitial;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    if (hasAvatar) {
      return Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            _InitialAvatar(initial: fallbackInitial, color: color),
      );
    }

    return _InitialAvatar(initial: fallbackInitial, color: color);
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.initial, required this.color});

  final String initial;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.14),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
