import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mapiafrontend/core/config/app_config.dart';
import 'package:mapiafrontend/core/network/api_endpoints.dart';
import 'package:mapiafrontend/features/news/domain/entities/map_news_item.dart';

class NewsMapApi {
  NewsMapApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<MapNewsItem>> fetchTodayMapNews() async {
    final base = Uri.parse(AppConfig.apiBaseUrl);
    final basePath = base.path.endsWith('/') ? base.path : '${base.path}/';
    final uri = base.replace(
      path: '$basePath${ApiEndpoints.newsTodayMap.substring(1)}',
    );
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'El backend respondio con estado ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    final rawItems = decoded is List ? decoded : const [];
    return [
      for (final item in rawItems)
        if (item is Map<String, dynamic>) MapNewsItem.fromJson(item),
    ];
  }
}
