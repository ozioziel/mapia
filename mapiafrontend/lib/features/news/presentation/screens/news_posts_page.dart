import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/news/domain/entities/generated_news_post.dart';
import 'package:mapiafrontend/features/news/domain/entities/news_status.dart';
import 'package:mapiafrontend/features/news/presentation/providers/news_posts_provider.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPostsPage extends StatefulWidget {
  const NewsPostsPage({super.key});

  @override
  State<NewsPostsPage> createState() => _NewsPostsPageState();
}

class _NewsPostsPageState extends State<NewsPostsPage> {
  late final NewsPostsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = NewsPostsProvider()..loadData();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _openOriginalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el enlace original.'),
          ),
        );
    }
  }

  void _openInMap(GeneratedNewsPost post) {
    Navigator.of(context).pushReplacementNamed(
      '/map',
      arguments: {'newsId': post.mapItemId ?? post.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      appBar: AppBar(
        title: const Text('Novedades MAPIA'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => _provider.refreshManual(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, _) {
            if (_provider.isLoading && _provider.posts.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (_provider.error != null && _provider.posts.isEmpty) {
              return _MessageState(
                icon: Icons.error_outline_rounded,
                title: 'Error de carga',
                message: _provider.error!,
                actionLabel: 'Reintentar',
                onAction: () => _provider.loadData(),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _provider.loadData(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _provider.posts.length + 2,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _NewsHeaderSection(
                      isRefreshing: _provider.isRefreshing,
                      onRefresh: () => _provider.refreshManual(),
                    );
                  }

                  if (index == 1) {
                    final status = _provider.status;
                    if (status == null) return const SizedBox.shrink();
                    return _NewsStatusCard(status: status);
                  }

                  final post = _provider.posts[index - 2];
                  return _NewsPostCard(
                    post: post,
                    onOpenOriginal: () => _openOriginalUrl(post.originalUrl),
                    onOpenMap: post.hasLocation ? () => _openInMap(post) : null,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NewsHeaderSection extends StatelessWidget {
  const _NewsHeaderSection({
    required this.isRefreshing,
    required this.onRefresh,
  });

  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF1F1), // Soft Bolivia Red
          Color(0xFFFFFEE5), // Soft Bolivia Yellow
          Color(0xFFF1FFF4), // Soft Bolivia Green
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.boliviaGreen,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Novedades MAPIA',
                  style: TextStyle(
                    color: AppTheme.textNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Publicaciones automáticas basadas en noticias recientes de Bolivia.',
                  style: TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Sincronizar RSS',
            onPressed: isRefreshing ? null : onRefresh,
            icon: isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.sync_rounded),
          ),
        ],
      ),
    );
  }
}

class _NewsStatusCard extends StatelessWidget {
  const _NewsStatusCard({required this.status});

  final NewsStatus status;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm:ss');
    final timeStr = status.lastPollTime != null
        ? dateFormat.format(status.lastPollTime!)
        : 'Nunca';

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: AppTheme.softBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.primaryBlue),
              const SizedBox(width: 6),
              const Text(
                'Estado del Polling',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textNavy,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Activo',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const Divider(height: 16, thickness: 0.8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusStat(label: 'Última revisión', value: timeStr),
              _StatusStat(label: 'Noticias', value: '${status.totalNewsDetected}'),
              _StatusStat(label: 'Posts creados', value: '${status.totalPostsGenerated}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusStat extends StatelessWidget {
  const _StatusStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.mutedText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.textNavy,
          ),
        ),
      ],
    );
  }
}

class _NewsPostCard extends StatelessWidget {
  const _NewsPostCard({
    required this.post,
    required this.onOpenOriginal,
    required this.onOpenMap,
  });

  final GeneratedNewsPost post;
  final VoidCallback onOpenOriginal;
  final VoidCallback? onOpenMap;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy, HH:mm', 'es').format(post.createdAt);

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppTheme.softBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Badge(
                label: post.source,
                icon: Icons.newspaper_rounded,
                color: AppTheme.boliviaRed,
              ),
              const SizedBox(width: 6),
              const _Badge(
                label: 'Desde RSS',
                icon: Icons.rss_feed_rounded,
                color: AppTheme.primaryBlue,
              ),
              const Spacer(),
              Text(
                dateStr,
                style: const TextStyle(
                  color: AppTheme.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.title,
            style: const TextStyle(
              color: AppTheme.textNavy,
              fontSize: 17,
              height: 1.22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post.content,
            style: const TextStyle(
              color: Color(0xFF434E5B),
              fontSize: 13.5,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const _Badge(
                label: 'Próximamente con IA',
                icon: Icons.auto_awesome_rounded,
                color: AppTheme.boliviaGreen,
              ),
              const Spacer(),
              if (onOpenMap != null) ...[
                TextButton.icon(
                  onPressed: onOpenMap,
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: const Text(
                    'Ver en mapa',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              TextButton.icon(
                onPressed: onOpenOriginal,
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text(
                  'Ver noticia',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12.5),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppCard(
          padding: const EdgeInsets.all(20),
          gradient: AppTheme.warmGradient,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppTheme.mutedText, size: 44),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
