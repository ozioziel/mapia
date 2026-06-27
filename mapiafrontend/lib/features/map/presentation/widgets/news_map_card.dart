import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/news/domain/entities/map_news_item.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';

class NewsMapCard extends StatelessWidget {
  const NewsMapCard({
    super.key,
    required this.item,
    required this.onClose,
    required this.onOpen,
  });

  final MapNewsItem item;
  final VoidCallback onClose;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final description = item.description;
    return AppCard(
      padding: const EdgeInsets.all(14),
      borderColor: AppTheme.softBorder,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _iconForCategory(item.category),
                color: _colorForCategory(item.category),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.category.label,
                  style: const TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Cerrar',
                onPressed: onClose,
                constraints: const BoxConstraints.tightFor(
                  width: 34,
                  height: 34,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textNavy,
              fontSize: 17,
              height: 1.18,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.source ?? 'MAPIA'} - ${DateFormat('d MMM, HH:mm', 'es').format(item.publishedAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onOpen != null)
                TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Ver novedad'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData newsIconForCategory(MapNewsCategory category) =>
    _iconForCategory(category);

IconData _iconForCategory(MapNewsCategory category) {
  return switch (category) {
    MapNewsCategory.bloqueo => Icons.warning_amber_rounded,
    MapNewsCategory.accidente => Icons.car_crash_rounded,
    MapNewsCategory.seguridad => Icons.security_rounded,
    MapNewsCategory.transporte => Icons.directions_bus_rounded,
    MapNewsCategory.clima => Icons.water_drop_rounded,
    MapNewsCategory.desastre => Icons.emergency_rounded,
    MapNewsCategory.servicios => Icons.bolt_rounded,
    MapNewsCategory.ambiente => Icons.park_rounded,
    MapNewsCategory.evento => Icons.event_rounded,
    MapNewsCategory.otroRelevante => Icons.info_rounded,
  };
}

Color _colorForCategory(MapNewsCategory category) {
  return switch (category) {
    MapNewsCategory.bloqueo => const Color(0xFFEA580C),
    MapNewsCategory.accidente => const Color(0xFFDC2626),
    MapNewsCategory.seguridad => const Color(0xFFE11D48),
    MapNewsCategory.transporte => const Color(0xFF2563EB),
    MapNewsCategory.clima => const Color(0xFF0891B2),
    MapNewsCategory.desastre => const Color(0xFF9333EA),
    MapNewsCategory.servicios => const Color(0xFFEAB308),
    MapNewsCategory.ambiente => AppTheme.boliviaGreen,
    MapNewsCategory.evento => const Color(0xFF7C3AED),
    MapNewsCategory.otroRelevante => AppTheme.primaryBlue,
  };
}
