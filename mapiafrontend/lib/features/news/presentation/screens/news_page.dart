import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/news/domain/entities/news_item.dart';
import 'package:mapiafrontend/features/news/presentation/providers/news_provider.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late final NewsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = NewsProvider()..loadNews();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _openNews(NewsItem item) async {
    final uri = Uri.tryParse(item.url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la noticia original.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      appBar: AppBar(
        title: const Text('Noticias'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => _provider.loadNews(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, _) {
            if (_provider.isLoading && _provider.items.isEmpty) {
              return const _NewsLoadingState();
            }

            if (_provider.error != null && _provider.items.isEmpty) {
              return _NewsMessageState(
                icon: Icons.cloud_off_rounded,
                title: 'No se pudo cargar el RSS',
                message: _provider.error!,
                actionLabel: 'Actualizar',
                onAction: _provider.loadNews,
              );
            }

            if (_provider.items.isEmpty) {
              return _NewsMessageState(
                icon: Icons.article_outlined,
                title: 'Sin noticias por ahora',
                message: 'El RSS de El Deber no devolvio noticias recientes.',
                actionLabel: 'Actualizar',
                onAction: _provider.loadNews,
              );
            }

            return RefreshIndicator(
              onRefresh: _provider.loadNews,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _provider.items.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _ExperimentalHeader(
                      isRefreshing: _provider.isLoading,
                      onRefresh: _provider.loadNews,
                    );
                  }

                  final item = _provider.items[index - 1];
                  return _NewsCard(item: item, onOpen: () => _openNews(item));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExperimentalHeader extends StatelessWidget {
  const _ExperimentalHeader({
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
        colors: [Color(0xFFFFF6D8), Color(0xFFEAF7F1), Colors.white],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.newspaper_rounded,
              color: AppTheme.boliviaGreen,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Busqueda Inteligente',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textNavy,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Experimental - RSS de El Deber para rutas y comunidad.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Actualizar',
            onPressed: isRefreshing ? null : onRefresh,
            icon: isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item, required this.onOpen});

  final NewsItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final description = item.description;
    final publishedAt = item.publishedAt;

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppTheme.softBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SourceBadge(source: item.source),
              const Spacer(),
              if (publishedAt != null)
                Flexible(
                  child: Text(
                    DateFormat('d MMM yyyy, HH:mm', 'es').format(publishedAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppTheme.mutedText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(
              color: AppTheme.textNavy,
              fontSize: 17.5,
              height: 1.16,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF4F5B6B),
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 13),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Abrir noticia'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.boliviaRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.rss_feed_rounded,
            color: AppTheme.boliviaRed,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            source,
            style: const TextStyle(
              color: AppTheme.boliviaRed,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsLoadingState extends StatelessWidget {
  const _NewsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _NewsMessageState extends StatelessWidget {
  const _NewsMessageState({
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
                  fontWeight: FontWeight.w700,
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
