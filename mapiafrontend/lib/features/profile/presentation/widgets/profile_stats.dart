import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({
    super.key,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    required this.likesCount,
  });

  final int postsCount;
  final int followersCount;
  final int followingCount;
  final int likesCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Row(
        children: [
          _StatItem(value: '$postsCount', label: context.l10n.publications),
          _StatItem(value: '$followersCount', label: context.l10n.followers),
          _StatItem(value: '$followingCount', label: context.l10n.following),
          _StatItem(value: _formatCount(likesCount), label: context.l10n.likes),
        ],
      ),
    );
  }

  String _formatCount(int value) {
    if (value < 1000) return '$value';
    final compact = value / 1000;
    return '${compact.toStringAsFixed(compact >= 10 ? 0 : 1)}K';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: AppTheme.textNavy,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
