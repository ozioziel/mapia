import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';

class PostInteractionBar extends StatelessWidget {
  const PostInteractionBar({
    super.key,
    required this.likesCount,
    required this.dislikesCount,
    required this.commentsCount,
    required this.userReaction,
    required this.isBusy,
    required this.onLikeTap,
    required this.onDislikeTap,
    required this.onReportTap,
    required this.onShareTap,
  });

  final int likesCount;
  final int dislikesCount;
  final int commentsCount;
  final String userReaction;
  final bool isBusy;
  final VoidCallback onLikeTap;
  final VoidCallback onDislikeTap;
  final VoidCallback onReportTap;
  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    final isLiked = userReaction == 'LIKE';
    final isDisliked = userReaction == 'DISLIKE';
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      children: [
        _ActionButton(
          icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border,
          label: '$likesCount',
          color: isLiked ? const Color(0xFFE53935) : const Color(0xFF5F6B7A),
          onTap: isBusy ? null : onLikeTap,
        ),
        _ActionButton(
          icon: isDisliked
              ? Icons.thumb_down_alt_rounded
              : Icons.thumb_down_alt_outlined,
          label: '$dislikesCount',
          color: isDisliked ? const Color(0xFFFFA000) : const Color(0xFF5F6B7A),
          onTap: isBusy ? null : onDislikeTap,
        ),
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: context.l10n.commentsCount(commentsCount),
          color: const Color(0xFF5F6B7A),
          onTap: null,
        ),
        _ActionButton(
          icon: Icons.flag_outlined,
          label: 'Falso',
          color: const Color(0xFF5F6B7A),
          onTap: isBusy ? null : onReportTap,
        ),
        _ActionButton(
          icon: Icons.ios_share_rounded,
          label: context.l10n.share,
          color: const Color(0xFF5F6B7A),
          onTap: isBusy ? null : onShareTap,
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
  final VoidCallback? onTap;

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
