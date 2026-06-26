import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/alerts/presentation/providers/alerts_provider.dart';
import 'package:mapiafrontend/features/alerts/presentation/widgets/alert_radius_selector.dart';
import 'package:mapiafrontend/features/alerts/presentation/widgets/nearby_alert_group_card.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late final AlertsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AlertsProvider()..loadGroups();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _openGroup(int index) {
    final group = _provider.groups[index];
    Navigator.of(
      context,
    ).pushNamed('/alerts/posts/${group.type.name}?radiusKm=${group.radiusKm}');
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed('/map');
      return;
    }
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/publications');
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushNamed('/create-post');
      return;
    }
    if (index == 3) return;
    if (index == 4) {
      Navigator.of(context).pushReplacementNamed('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        title: Text(context.l10n.alertsNearYou),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textNavy,
        elevation: 0,
      ),
      bottomNavigationBar: _AlertsBottomNavigation(
        currentIndex: 3,
        onIndexChanged: _onBottomNavTap,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, _) {
            return RefreshIndicator(
              onRefresh: _provider.loadGroups,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                children: [
                  _LocationSummary(address: _provider.currentLocation.address),
                  const SizedBox(height: 18),
                  _SectionTitle(context.l10n.radius),
                  const SizedBox(height: 10),
                  AlertRadiusSelector(
                    optionsKm: _provider.radiusOptionsKm,
                    selectedRadiusKm: _provider.selectedRadiusKm,
                    onSelected: _provider.selectRadius,
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(context.l10n.nearbySummary),
                  const SizedBox(height: 12),
                  if (_provider.isLoading && _provider.groups.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 52),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_provider.error != null)
                    _AlertsMessage(
                      icon: Icons.info_outline_rounded,
                      message: _provider.error!,
                      actionLabel: context.l10n.retry,
                      onAction: _provider.loadGroups,
                    )
                  else if (_provider.groups.isEmpty)
                    _AlertsMessage(
                      icon: Icons.nearby_off_rounded,
                      message: context.l10n.noNearbyPosts,
                    )
                  else
                    ...List.generate(_provider.groups.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NearbyAlertGroupCard(
                          group: _provider.groups[index],
                          onTap: () => _openGroup(index),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LocationSummary extends StatelessWidget {
  const _LocationSummary({required this.address});

  final String? address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8EF)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F7EF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: Color(0xFF0B8063),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.currentLocation,
                  style: const TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address ?? context.l10n.defaultCity,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textNavy,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AlertsMessage extends StatelessWidget {
  const _AlertsMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 44),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.mutedText, size: 42),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _AlertsBottomNavigation extends StatelessWidget {
  const _AlertsBottomNavigation({
    required this.currentIndex,
    required this.onIndexChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(
        context.l10n.map,
        Icons.map_rounded,
        const Color(0xFFE53935),
      ),
      _NavItemData(
        context.l10n.explore,
        Icons.travel_explore_rounded,
        const Color(0xFFE53935),
      ),
      _NavItemData(
        context.l10n.publish,
        Icons.add_rounded,
        const Color(0xFFFFB300),
      ),
      _NavItemData(
        context.l10n.alerts,
        Icons.notifications_none_rounded,
        const Color(0xFF0B8063),
      ),
      _NavItemData(
        context.l10n.profile,
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
            const Row(
              children: [
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
