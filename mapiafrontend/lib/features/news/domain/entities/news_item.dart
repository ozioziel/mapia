class NewsItem {
  const NewsItem({
    required this.title,
    required this.source,
    required this.url,
    this.publishedAt,
    this.description,
  });

  final String title;
  final String source;
  final String url;
  final DateTime? publishedAt;
  final String? description;

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    final publishedAt = json['publishedAt'];

    return NewsItem(
      title: json['title'] as String? ?? '',
      source: json['source'] as String? ?? 'El Deber',
      url: json['url'] as String? ?? '',
      publishedAt: publishedAt is String
          ? DateTime.tryParse(publishedAt)
          : null,
      description: json['description'] as String?,
    );
  }
}
