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
        context.l10n.publish,
        Icons.add_rounded,
        AppTheme.boliviaYellow,
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

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white),
          boxShadow: AppTheme.liftedShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const Row(
                children: [
                  Expanded(child: _BoliviaStripe(color: AppTheme.boliviaRed)),
                  Expanded(
                    child: _BoliviaStripe(color: AppTheme.boliviaYellow),
                  ),
                  Expanded(child: _BoliviaStripe(color: AppTheme.boliviaGreen)),
                ],
              ),
            ),
            const SizedBox(height: 5),
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
                offset: const Offset(0, -11),
                child: const _PublishCircle(),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44,
                height: 34,
                decoration: BoxDecoration(
                  color: active
                      ? data.color.withValues(alpha: 0.13)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  data.icon,
                  color: active ? data.color : const Color(0xFF617083),
                  size: 22,
                ),
              ),
            SizedBox(height: prominent ? 0 : 2),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? data.color : const Color(0xFF617083),
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
          colors: [Color(0xFFFFCA55), Color(0xFFFFA726)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppTheme.boliviaYellow.withValues(alpha: 0.38),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.add_rounded, color: AppTheme.textNavy, size: 34),
    );
  }
}
