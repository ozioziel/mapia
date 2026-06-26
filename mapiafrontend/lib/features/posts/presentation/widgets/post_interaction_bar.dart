import 'package:flutter/material.dart';

class PostInteractionBar extends StatelessWidget {
  const PostInteractionBar({
    super.key,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.onLikeTap,
    required this.onShareTap,
  });

  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      children: [
        _ActionButton(
          icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border,
          label: '$likesCount',
          color: isLiked ? const Color(0xFFE53935) : const Color(0xFF5F6B7A),
          onTap: onLikeTap,
        ),
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: '$commentsCount comentarios',
          color: const Color(0xFF5F6B7A),
          onTap: () {},
        ),
        _ActionButton(
          icon: Icons.ios_share_rounded,
          label: 'Compartir',
          color: const Color(0xFF5F6B7A),
          onTap: onShareTap,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
      icon: Icon(icon, size: 20, color: color),
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
