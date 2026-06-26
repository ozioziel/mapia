import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapiafrontend/core/config/app_config.dart';
import 'package:mapiafrontend/features/news/data/models/generated_news_post_model.dart';
import 'package:mapiafrontend/features/news/data/models/news_status_model.dart';

class NewsRemoteDataSource {
  const NewsRemoteDataSource({this.client});

  static final String apiBaseUrl = (() {
    const env = String.fromEnvironment('MAPIA_API_BASE_URL', defaultValue: '');
    return env.isNotEmpty ? env : AppConfig.apiBaseUrl;
  })();

  final http.Client? client;

  Future<List<GeneratedNewsPostModel>> fetchGeneratedPosts() async {
    final httpClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    try {
      final response = await httpClient.get(
        Uri.parse('$apiBaseUrl/news/generated-posts'),
        headers: const {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('El backend respondió con estado ${response.statusCode}.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const FormatException('Formato de respuesta inesperado.');
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(GeneratedNewsPostModel.fromJson)
          .toList();
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }
  }

  Future<NewsStatusModel> fetchStatus() async {
    final httpClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    try {
      final response = await httpClient.get(
        Uri.parse('$apiBaseUrl/news/status'),
        headers: const {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('El backend respondió con estado ${response.statusCode}.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Formato de respuesta inesperado.');
      }

      return NewsStatusModel.fromJson(decoded);
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }
  }

  Future<void> refreshNews() async {
    final httpClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    try {
      final response = await httpClient.post(
        Uri.parse('$apiBaseUrl/news/refresh'),
        headers: const {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('El backend respondió con estado ${response.statusCode}.');
      }
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }
  }
}
