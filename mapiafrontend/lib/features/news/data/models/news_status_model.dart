import 'package:mapiafrontend/features/news/domain/entities/news_status.dart';

class NewsStatusModel extends NewsStatus {
  const NewsStatusModel({
    super.lastPollTime,
    required super.totalNewsDetected,
    required super.totalPostsGenerated,
    required super.activeSources,
    required super.configuredInterval,
  });

  factory NewsStatusModel.fromJson(Map<String, dynamic> json) {
    final activeSourcesRaw = json['activeSources'];
    final activeSources = activeSourcesRaw is List
        ? activeSourcesRaw.map((e) => e.toString()).toList()
        : <String>[];

    return NewsStatusModel(
      lastPollTime: json['lastPollTime'] != null
          ? DateTime.tryParse(json['lastPollTime'] as String)
          : null,
      totalNewsDetected: json['totalNewsDetected'] as int? ?? 0,
      totalPostsGenerated: json['totalPostsGenerated'] as int? ?? 0,
      activeSources: activeSources,
      configuredInterval: json['configuredInterval'] as String? ?? 'Cada 30 minutos',
    );
  }
}
