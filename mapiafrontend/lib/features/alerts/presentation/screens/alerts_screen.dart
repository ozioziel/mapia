import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/alerts/presentation/providers/alerts_provider.dart';
import 'package:mapiafrontend/features/alerts/presentation/widgets/alert_radius_selector.dart';
import 'package:mapiafrontend/features/alerts/presentation/widgets/nearby_alert_group_card.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';
import 'package:mapiafrontend/shared/widgets/mapia_bottom_navigation.dart';

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
    if (index == 2) return;
    if (index == 3) {
      Navigator.of(context).pushReplacementNamed('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      appBar: AppBar(title: Text(context.l10n.alertsNearYou)),
      bottomNavigationBar: MapiaBottomNavigation(
        currentIndex: 2,
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
    return AppCard(
      padding: const EdgeInsets.all(16),
      gradient: AppTheme.mintGradient,
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
