import 'package:mapiafrontend/features/map/types/alert_map_types.dart';

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.createdAt,
    this.incidents = const [],
  });

  final String text;
  final bool isUser;
  final DateTime createdAt;

  /// Incidencias adjuntas a una respuesta del asistente (para pintar tarjetas).
  final List<AlertMapItem> incidents;
}
