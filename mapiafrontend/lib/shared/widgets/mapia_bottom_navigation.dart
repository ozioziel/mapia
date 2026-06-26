import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';

class MapiaBottomNavigation extends StatelessWidget {
  const MapiaBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(context.l10n.map, Icons.map_rounded, AppTheme.boliviaRed),
      _NavItemData(
        context.l10n.explore,
        Icons.travel_explore_rounded,
        AppTheme.primaryBlue,
      ),
      _NavItemData(
        context.l10n.alerts,
        Icons.notifications_none_rounded,
        AppTheme.coral,
      ),
      _NavItemData(
        context.l10n.profile,
        Icons.person_outline_rounded,
        AppTheme.boliviaGreen,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _BottomNavButton(
                    data: items[i],
                    active: currentIndex == i,
                    onTap: () => onIndexChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
    required this.onTap,
  });

  final _NavItemData data;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: active
                    ? data.color.withValues(alpha: 0.13)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                data.icon,
                color: active ? data.color : const Color(0xFF94A3B8),
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? data.color : const Color(0xFF94A3B8),
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
