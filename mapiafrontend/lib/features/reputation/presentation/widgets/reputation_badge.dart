import 'package:flutter/material.dart';
import 'package:mapiafrontend/features/reputation/domain/reputation_helper.dart';

class ReputationBadge extends StatelessWidget {
  const ReputationBadge({
    super.key,
    required this.reputation,
    this.compact = false,
  });

  final ReputationInfo reputation;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = compact
        ? reputation.hasReputation
              ? 'Rep. ${reputation.score}'
              : 'Sin reputación'
        : reputation.hasReputation
        ? '${reputation.label} · ${reputation.score}'
        : 'Sin reputación';

    return Container(
      constraints: BoxConstraints(maxWidth: compact ? 104 : 190),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: reputation.softColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: reputation.color.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            reputation.hasReputation
                ? Icons.speed_rounded
                : Icons.speed_outlined,
            color: reputation.color,
            size: compact ? 13 : 15,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: reputation.color,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
