import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mapiafrontend/core/config/app_config.dart';
import 'package:mapiafrontend/features/news/domain/entities/news_item.dart';

// Experimental: isolated client for the backend El Deber RSS proxy.
// Override with: --dart-define=MAPIA_API_BASE_URL=http://<host>:3000/api/v1
class NewsRssService {
  const NewsRssService({this.client});

  static final String apiBaseUrl = (() {
    const env = String.fromEnvironment('MAPIA_API_BASE_URL', defaultValue: '');
    return env.isNotEmpty ? env : AppConfig.apiBaseUrl;
  })();
  static final String endpoint = '$apiBaseUrl/experimental/news/el-deber';

  final http.Client? client;

  Future<List<NewsItem>> fetchElDeberNews() async {
    final httpClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    try {
      final response = await httpClient
          .get(
            Uri.parse(endpoint),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NewsRssException(
          'El backend respondio con estado ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const NewsRssException(
          'El backend devolvio un formato inesperado.',
        );
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(NewsItem.fromJson)
          .where((item) => item.title.isNotEmpty && item.url.isNotEmpty)
          .toList(growable: false);
    } on NewsRssException {
      rethrow;
    } on FormatException catch (error) {
      throw NewsRssException(
        'No se pudo leer la respuesta de noticias: $error',
      );
    } catch (error) {
      throw NewsRssException('No se pudieron cargar las noticias: $error');
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }
  }
}

class NewsRssException implements Exception {
  const NewsRssException(this.message);

  final String message;

  @override
  String toString() => message;
}
