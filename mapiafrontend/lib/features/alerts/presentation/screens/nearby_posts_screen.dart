import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/localization/localized_post_type.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/alerts/presentation/providers/alerts_provider.dart';
import 'package:mapiafrontend/features/alerts/presentation/widgets/nearby_post_card.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';

class NearbyPostsScreen extends StatefulWidget {
  const NearbyPostsScreen({
    super.key,
    required this.type,
    required this.radiusKm,
  });

  final PostType type;
  final double radiusKm;

  @override
  State<NearbyPostsScreen> createState() => _NearbyPostsScreenState();
}

class _NearbyPostsScreenState extends State<NearbyPostsScreen> {
  late final AlertsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AlertsProvider()..loadPostsByType(widget.type, widget.radiusKm);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _openPost(PostEntity post) {
    Navigator.of(context).pushNamed('/posts/${Uri.encodeComponent(post.id)}');
  }

  @override
  Widget build(BuildContext context) {
    final option = widget.type.option;

    return AppGradientScaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.postsNearYou(widget.type.pluralLabel(context)),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, _) {
            if (_provider.isLoading && _provider.nearbyPosts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_provider.error != null) {
              return _PostsMessage(
                message: _provider.error!,
                onRetry: () {
                  _provider.loadPostsByType(widget.type, widget.radiusKm);
                },
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: _provider.nearbyPosts.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _NearbyPostsHeader(
                    icon: option.icon,
                    color: option.color,
                    radiusKm: widget.radiusKm,
                    address: _provider.currentLocation.address,
                  );
                }

                final post = _provider.nearbyPosts[index - 1];
                return NearbyPostCard(post: post, onTap: () => _openPost(post));
              },
            );
          },
        ),
      ),
    );
  }
}

class _NearbyPostsHeader extends StatelessWidget {
  const _NearbyPostsHeader({
    required this.icon,
    required this.color,
    required this.radiusKm,
    required this.address,
  });

  final IconData icon;
  final Color color;
  final double radiusKm;
  final String? address;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      gradient: LinearGradient(
        colors: [color.withValues(alpha: 0.08), Colors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.radiusKm(radiusKm.toStringAsFixed(0)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.locationWithAddress(
                    address ?? context.l10n.defaultCity,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
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

class _PostsMessage extends StatelessWidget {
  const _PostsMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppTheme.mutedText,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}
