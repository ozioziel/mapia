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
  ChatbotApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

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
}
