import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ReputationTier { none, low, medium, good, excellent }

class ReputationInfo {
  const ReputationInfo({
    required this.score,
    required this.postsCount,
    required this.tier,
    required this.label,
    required this.color,
    required this.softColor,
  });

  final int? score;
  final int postsCount;
  final ReputationTier tier;
  final String label;
  final Color color;
  final Color softColor;

  bool get hasReputation => postsCount > 0 && score != null;

  double get progress {
    if (!hasReputation) return 0;
    return (score!.clamp(0, 100)) / 100;
  }
}

ReputationInfo reputationInfoFor({
  required int? score,
  required int postsCount,
}) {
  final normalizedScore = score?.clamp(0, 100);

  if (postsCount <= 0 || normalizedScore == null || normalizedScore == 0) {
    return const ReputationInfo(
      score: null,
      postsCount: 0,
      tier: ReputationTier.none,
      label: 'Sin reputación',
      color: Color(0xFF8792A2),
      softColor: Color(0xFFE8ECF1),
    );
  }

  if (normalizedScore < 40) {
    return ReputationInfo(
      score: normalizedScore,
      postsCount: postsCount,
      tier: ReputationTier.low,
      label: 'Reputación baja',
      color: const Color(0xFFC75D58),
      softColor: const Color(0xFFF8E8E6),
    );
  }

  if (normalizedScore < 70) {
    return ReputationInfo(
      score: normalizedScore,
      postsCount: postsCount,
      tier: ReputationTier.medium,
      label: 'Reputación media',
      color: const Color(0xFFD38B25),
      softColor: const Color(0xFFFFF0D6),
    );
  }

  if (normalizedScore < 90) {
    return ReputationInfo(
      score: normalizedScore,
      postsCount: postsCount,
      tier: ReputationTier.good,
      label: 'Buena reputación',
      color: const Color(0xFF278160),
      softColor: const Color(0xFFE4F4ED),
    );
  }

  return ReputationInfo(
    score: normalizedScore,
    postsCount: postsCount,
    tier: ReputationTier.excellent,
    label: 'Excelente reputación',
    color: const Color(0xFF147A7B),
    softColor: const Color(0xFFDFF5F3),
  );
}

ReputationInfo profileReputationInfo({
  required int postsCount,
  required int likesCount,
  required int followersCount,
}) {
  if (postsCount <= 0) {
    return reputationInfoFor(score: null, postsCount: postsCount);
  }

  final averageLikes = likesCount / math.max(postsCount, 1);
  final likesScore = (averageLikes / 50).clamp(0, 1) * 45;
  final communityScore = (followersCount / 500).clamp(0, 1) * 25;
  final consistencyScore = (postsCount / 20).clamp(0, 1) * 20;
  final score = (10 + likesScore + communityScore + consistencyScore).round();

  return reputationInfoFor(score: score, postsCount: postsCount);
}

ReputationInfo authorReputationInfo(String authorName) {
  return reputationInfoFor(score: null, postsCount: 0);
}
