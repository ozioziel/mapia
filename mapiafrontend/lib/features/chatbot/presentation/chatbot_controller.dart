import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapiafrontend/features/chatbot/data/chatbot_api.dart';
import 'package:mapiafrontend/features/chatbot/models/chat_message.dart';
import 'package:mapiafrontend/features/map/services/map_api.dart';
import 'package:mapiafrontend/features/map/types/alert_map_types.dart';

/// Orquesta el asistente: intenta el backend `/chatbot/ask` y, si falla
/// (no desplegado / sin red), cae a una búsqueda local de incidencias.
class ChatbotController extends ChangeNotifier {
  ChatbotController({ChatbotApi? chatbotApi, MapApi? mapApi})
    : _chatbotApi = chatbotApi ?? ChatbotApi(),
      _mapApi = mapApi ?? MapApi();

  /// Instancia compartida a nivel de app: mantiene el historial del chat aunque
  /// el panel se cierre y se reabra, o se navegue entre pantallas.
  static final ChatbotController shared = ChatbotController();

  final ChatbotApi _chatbotApi;
  final MapApi _mapApi;

  final List<ChatMessage> messages = [
    ChatMessage(
      text:
          'Hola, soy el Asistente MAPIA. Pregúntame por las incidencias '
          'registradas: bloqueos, combustible, sobreprecios… y te muestro las '
          'que hay (por zona o cerca de ti).',
      isUser: false,
      createdAt: DateTime.now(),
    ),
  ];

  bool _isSending = false;
  bool get isSending => _isSending;

  Future<void> send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || _isSending) return;

    messages.add(
      ChatMessage(text: text, isUser: true, createdAt: DateTime.now()),
    );
    _isSending = true;
    notifyListeners();

    final position = await _lastKnownPosition();

    ChatMessage reply;
    try {
      final result = await _chatbotApi.ask(
        text,
        lat: position?.latitude,
        lng: position?.longitude,
      );
      reply = ChatMessage(
        text: result.reply,
        isUser: false,
        createdAt: DateTime.now(),
        incidents: result.incidents,
      );
    } catch (_) {
      reply = await _localFallback(text, position);
    }

    messages.add(reply);
    _isSending = false;
    notifyListeners();
  }

  Future<Position?> _lastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  /// Búsqueda local de incidencias cuando el backend no responde.
  Future<ChatMessage> _localFallback(String text, Position? position) async {
    try {
      final filters = _filtersFromText(text, position);
      final incidents = await _mapApi.fetchAlerts(filters);
      return ChatMessage(
        text: _composeReply(incidents, filters),
        isUser: false,
        createdAt: DateTime.now(),
        incidents: incidents.take(8).toList(),
      );
    } catch (_) {
      return ChatMessage(
        text:
            'No pude consultar las incidencias en este momento. Revisa tu '
            'conexión e inténtalo de nuevo.',
        isUser: false,
        createdAt: DateTime.now(),
      );
    }
  }

  AlertFilters _filtersFromText(String text, Position? position) {
    final s = _normalize(text);

    AlertType? type;
    if (s.contains('bloqueo') || s.contains('marcha') || s.contains('paro')) {
      type = AlertType.bloqueo;
    } else if (s.contains('combustible') ||
        s.contains('gasolina') ||
        s.contains('diesel') ||
        s.contains('gnv')) {
      type = AlertType.combustible;
    } else if (s.contains('precio') || s.contains('caro') || s.contains('sobreprecio')) {
      type = AlertType.sobreprecio;
    } else if (s.contains('no hay') || s.contains('agotado') || s.contains('desabastec')) {
      type = AlertType.productoNoDisponible;
    }

    final severity =
        (s.contains('grave') || s.contains('urgente') || s.contains('alta'))
        ? AlertSeverity.high
        : null;

    String? department;
    String? municipality;
    if (s.contains('el alto')) {
      municipality = 'El Alto';
    } else if (s.contains('la paz')) {
      department = 'La Paz';
    } else if (s.contains('santa cruz')) {
      department = 'Santa Cruz';
    } else if (s.contains('cochabamba')) {
      department = 'Cochabamba';
    }

    final wantsNear =
        s.contains('cerca') || s.contains('aqui') || s.contains('mi ubicacion');

    return AlertFilters(
      alertType: type,
      severity: severity,
      department: department,
      municipality: municipality,
      latitude: wantsNear ? position?.latitude : null,
      longitude: wantsNear ? position?.longitude : null,
      radiusKm: wantsNear && position != null ? 5 : null,
    );
  }

  String _composeReply(List<AlertMapItem> incidents, AlertFilters filters) {
    if (incidents.isEmpty) {
      return 'No encontré incidencias registradas con esos criterios. '
          'Prueba ampliando la búsqueda o revisa el mapa.';
    }
    final shown = incidents.take(8).toList();
    final lines = <String>[];
    for (var i = 0; i < shown.length; i++) {
      final it = shown[i];
      final place = it.zone ?? it.municipality ?? it.department ?? 'ubicación no especificada';
      lines.add('${i + 1}. ${it.title} · ${it.severity.label} · $place');
    }
    final n = shown.length;
    return 'Encontré $n incidencia${n == 1 ? '' : 's'} registrada${n == 1 ? '' : 's'}:\n'
        '${lines.join('\n')}';
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp('[áàä]'), 'a')
        .replaceAll(RegExp('[éèë]'), 'e')
        .replaceAll(RegExp('[íìï]'), 'i')
        .replaceAll(RegExp('[óòö]'), 'o')
        .replaceAll(RegExp('[úùü]'), 'u');
  }
}
