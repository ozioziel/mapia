class NewsStatus {
  const NewsStatus({
    this.lastPollTime,
    required this.totalNewsDetected,
    required this.totalPostsGenerated,
    required this.activeSources,
    required this.configuredInterval,
  });

  final DateTime? lastPollTime;
  final int totalNewsDetected;
  final int totalPostsGenerated;
  final List<String> activeSources;
  final String configuredInterval;
}
