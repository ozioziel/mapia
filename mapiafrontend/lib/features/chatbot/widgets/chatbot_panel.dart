import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/chatbot/models/chat_message.dart';

class ChatbotPanel extends StatefulWidget {
  const ChatbotPanel({super.key, required this.onClose, this.compact = false});

  final VoidCallback onClose;
  final bool compact;

  @override
  State<ChatbotPanel> createState() => _ChatbotPanelState();
}

class _ChatbotPanelState extends State<ChatbotPanel> {
  static const List<String> _suggestions = [
    'Quiero ir al Multicine',
    '¿Qué hay por aquí cerca?',
    'Muéstrame rutas populares',
    '¿Hay bloqueos en el camino?',
    'Recomiéndame lugares cerca',
    'Buscar eventos en La Paz',
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Hola, soy el Asistente MAPIA. Estoy en modo prueba y puedo simular ayuda sobre rutas, lugares y alertas.',
      isUser: false,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendText([String? value]) {
    final text = (value ?? _controller.text).trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, createdAt: DateTime.now()),
      );
      _messages.add(
        ChatMessage(
          text: _fakeAssistantReply(text),
          isUser: false,
          createdAt: DateTime.now(),
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  String _fakeAssistantReply(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('multicine')) {
      return 'Puedo ayudarte a encontrar una ruta hacia el Multicine. Por ahora esta es una vista de prueba, pero aquí aparecerán recomendaciones de rutas, lugares cercanos y alertas importantes.';
    }
    if (normalized.contains('bloqueo') ||
        normalized.contains('bloqueos') ||
        normalized.contains('tramite') ||
        normalized.contains('trámite')) {
      return 'En una versión futura revisaré noticias y alertas para avisarte si existen bloqueos, tráfico o problemas en la ruta. Por ahora esta respuesta es simulada.';
    }
    if (normalized.contains('cerca')) {
      return 'Pronto podré mostrarte lugares cercanos, rutas recomendadas y puntos útiles dentro de MAPIA. Por ahora esta respuesta es solo visual.';
    }
    if (normalized.contains('ruta') || normalized.contains('rutas')) {
      return 'Todavía estoy en modo prueba, pero la idea es ayudarte a comparar rutas populares, tiempos aproximados y alertas relevantes.';
    }
    if (normalized.contains('evento') || normalized.contains('eventos')) {
      return 'En una versión futura podré sugerirte eventos y noticias de La Paz conectados a tu ubicación o búsqueda.';
    }
    return 'Todavía estoy en modo prueba, pero pronto podré ayudarte con rutas, lugares, noticias y recomendaciones dentro de MAPIA.';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: widget.compact ? bottomInset : 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(28),
            bottom: Radius.circular(widget.compact ? 0 : 28),
          ),
          boxShadow: AppTheme.liftedShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _ChatHeader(onClose: widget.onClose),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                itemCount: _messages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _MessageBubble(message: message);
                },
              ),
            ),
            _SuggestionChips(suggestions: _suggestions, onSelected: _sendText),
            _ChatInput(controller: _controller, onSend: _sendText),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF6E3), Color(0xFFEAF7F1)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  AppTheme.boliviaRed,
                  AppTheme.boliviaYellow,
                  AppTheme.boliviaGreen,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.boliviaGreen.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Asistente MAPIA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Pregúntame sobre rutas, lugares o noticias',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cerrar asistente',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 310),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isUser ? AppTheme.primaryBlue : const Color(0xFFF4F7F4),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isUser ? 18 : 5),
              bottomRight: Radius.circular(isUser ? 5 : 18),
            ),
            border: isUser ? null : Border.all(color: const Color(0xFFE1E7DE)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : AppTheme.textNavy,
                fontSize: 13.5,
                height: 1.32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({required this.suggestions, required this.onSelected});

  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final text = suggestions[index];
          return ActionChip(
            onPressed: () => onSelected(text),
            avatar: const Icon(Icons.bolt_rounded, size: 16),
            label: Text(text),
            labelStyle: const TextStyle(
              color: AppTheme.textNavy,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            backgroundColor: const Color(0xFFFFF6DD),
            side: const BorderSide(color: Color(0xFFFFE1A8)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Escribe tu mensaje',
                  prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 48,
              height: 48,
              child: FilledButton(
                onPressed: onSend,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  backgroundColor: AppTheme.boliviaGreen,
                ),
                child: const Icon(Icons.send_rounded, size: 21),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
