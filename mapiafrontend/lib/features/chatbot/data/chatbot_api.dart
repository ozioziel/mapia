import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mapiafrontend/core/network/api_client.dart';
import 'package:mapiafrontend/core/network/api_endpoints.dart';
import 'package:mapiafrontend/features/map/types/alert_map_types.dart';

/// Respuesta del asistente: texto + incidencias para pintar como tarjetas.
class ChatbotReply {
  const ChatbotReply({
    required this.reply,
    required this.incidents,
    required this.usedAi,
  });

  final String reply;
  final List<AlertMapItem> incidents;
  final bool usedAi;
}

class ChatbotApi {
  ChatbotApi({ApiClient? client, http.Client? httpClient})
    : _client = client ?? ApiClient(),
      _http = httpClient ?? http.Client();

  final ApiClient _client;
  final http.Client _http;

  Future<ChatbotReply> ask(String message, {double? lat, double? lng}) async {
    final json = await _client.postJson(ApiEndpoints.chatbotAsk, {
      'message': message,
      'lat': ?lat,
      'lng': ?lng,
    });

    final rawItems = json['incidents'] as List? ?? const [];
    return ChatbotReply(
      reply: json['reply'] as String? ?? '',
      incidents: [
        for (final item in rawItems)
          if (item is Map<String, dynamic>) AlertMapItem.fromJson(item),
      ],
      usedAi: json['usedAi'] as bool? ?? false,
    );
  }

  /// Sube un archivo de audio y devuelve la transcripción (OpenAI Whisper).
  Future<String> transcribe(String audioPath) async {
    final request = http.MultipartRequest(
      'POST',
      _client.uri(ApiEndpoints.chatbotTranscribe),
    )..files.add(await http.MultipartFile.fromPath('audio', audioPath));

    final streamed = await _http
        .send(request)
        .timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'La transcripción falló (estado ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return (decoded['text'] as String? ?? '').trim();
    }
    return '';
  }
}
