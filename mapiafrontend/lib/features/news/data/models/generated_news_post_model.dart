import 'package:mapiafrontend/features/news/domain/entities/generated_news_post.dart';

class GeneratedNewsPostModel extends GeneratedNewsPost {
  const GeneratedNewsPostModel({
    required super.id,
    required super.title,
    required super.content,
    required super.source,
    required super.originalUrl,
    required super.category,
    required super.status,
    required super.generatedBy,
    required super.isAiGenerated,
    required super.createdAt,
    super.mapItemId,
    super.locationText,
    super.latitude,
    super.longitude,
    super.publishedAt,
  });

  factory GeneratedNewsPostModel.fromJson(Map<String, dynamic> json) {
    return GeneratedNewsPostModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      source: json['source'] as String? ?? '',
      originalUrl: json['originalUrl'] as String? ?? '',
      category: json['category'] as String? ?? 'novedad',
      status: json['status'] as String? ?? 'published',
      generatedBy: json['generatedBy'] as String? ?? 'rss_polling',
      isAiGenerated: json['isAiGenerated'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      mapItemId: json['mapItemId'] as String?,
      locationText: json['locationText'] as String?,
      latitude: (json['lat'] as num?)?.toDouble(),
      longitude: (json['lng'] as num?)?.toDouble(),
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
    );
  }
}
