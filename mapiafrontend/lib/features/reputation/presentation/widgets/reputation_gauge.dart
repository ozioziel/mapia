import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/reputation/domain/reputation_helper.dart';

class ReputationGauge extends StatelessWidget {
  const ReputationGauge({
    super.key,
    required this.reputation,
    this.width = 190,
    this.height = 120,
  });

  final ReputationInfo reputation;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ReputationGaugePainter(reputation),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reputation.hasReputation ? '${reputation.score}' : '--',
                  style: TextStyle(
                    color: reputation.hasReputation
                        ? reputation.color
                        : AppTheme.mutedText,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'de 100',
                  style: TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReputationGaugePainter extends CustomPainter {
  const _ReputationGaugePainter(this.reputation);

  final ReputationInfo reputation;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = math.max(12.0, size.width * 0.075);
    final center = Offset(size.width / 2, size.height - 8);
    final radius = math.min(size.width / 2, size.height) - strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = const Color(0xFFE4E9EF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [reputation.color.withValues(alpha: 0.62), reputation.color],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);
    if (reputation.progress > 0) {
      canvas.drawArc(
        rect,
        math.pi,
        math.pi * reputation.progress,
        false,
        progressPaint,
      );
    }

    final angle = math.pi + (math.pi * reputation.progress);
    final needleLength = radius - strokeWidth * 0.85;
    final needleEnd = Offset(
      center.dx + math.cos(angle) * needleLength,
      center.dy + math.sin(angle) * needleLength,
    );
    final needlePaint = Paint()
      ..color = reputation.hasReputation
          ? reputation.color
          : const Color(0xFF98A2B3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 6.5, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      4.2,
      Paint()
        ..color = reputation.hasReputation
            ? reputation.color
            : const Color(0xFF98A2B3),
    );
  }

  @override
  bool shouldRepaint(covariant _ReputationGaugePainter oldDelegate) {
    return oldDelegate.reputation.score != reputation.score ||
        oldDelegate.reputation.postsCount != reputation.postsCount;
  }
}
