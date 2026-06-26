import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/reputation/domain/reputation_helper.dart';
import 'package:mapiafrontend/features/reputation/presentation/widgets/reputation_gauge.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';

class ReputationSummaryCard extends StatelessWidget {
  const ReputationSummaryCard({super.key, required this.reputation});

  final ReputationInfo reputation;

  @override
  Widget build(BuildContext context) {
    final title = reputation.hasReputation
        ? reputation.label
        : 'Aún no hay reputación';
    final description = reputation.hasReputation
        ? 'La reputación se calcula según tus publicaciones, reportes útiles e interacción de la comunidad.'
        : 'Publica reportes útiles para que la comunidad pueda valorar tus aportes.';

    return AppCard(
      padding: const EdgeInsets.all(18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, reputation.softColor.withValues(alpha: 0.72)],
      ),
      borderColor: reputation.color.withValues(alpha: 0.15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          final gauge = Center(
            child: ReputationGauge(
              reputation: reputation,
              width: isCompact ? 170 : 190,
              height: isCompact ? 110 : 120,
            ),
          );
          final copy = _ReputationCopy(
            reputation: reputation,
            title: title,
            description: description,
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [copy, const SizedBox(height: 14), gauge],
            );
          }

          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 16),
              gauge,
            ],
          );
        },
      ),
    );
  }
}

class _ReputationCopy extends StatelessWidget {
  const _ReputationCopy({
    required this.reputation,
    required this.title,
    required this.description,
  });

  final ReputationInfo reputation;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: reputation.softColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: reputation.color,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Reputación',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textNavy,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textNavy,
            fontSize: 20,
            height: 1.14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          description,
          style: const TextStyle(
            color: AppTheme.mutedText,
            fontSize: 13.5,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
