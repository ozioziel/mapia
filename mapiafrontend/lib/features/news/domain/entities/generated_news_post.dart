class GeneratedNewsPost {
  const GeneratedNewsPost({
    required this.id,
    required this.title,
    required this.content,
    required this.source,
    required this.originalUrl,
    required this.category,
    required this.status,
    required this.generatedBy,
    required this.isAiGenerated,
    required this.createdAt,
    this.mapItemId,
    this.locationText,
    this.latitude,
    this.longitude,
    this.publishedAt,
  });

  final String id;
  final String title;
  final String content;
  final String source;
  final String originalUrl;
  final String category;
  final String status;
  final String generatedBy;
  final bool isAiGenerated;
  final DateTime createdAt;
  final String? mapItemId;
  final String? locationText;
  final double? latitude;
  final double? longitude;
  final DateTime? publishedAt;

  bool get hasLocation => latitude != null && longitude != null;
}
