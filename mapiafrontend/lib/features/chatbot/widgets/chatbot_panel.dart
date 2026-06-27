import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/chatbot/models/chat_message.dart';
import 'package:mapiafrontend/features/chatbot/presentation/chatbot_controller.dart';
import 'package:mapiafrontend/features/map/types/alert_map_types.dart';
import 'package:mapiafrontend/features/map/utils/severity.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ChatbotPanel extends StatefulWidget {
  const ChatbotPanel({super.key, required this.onClose, this.compact = false});

  final VoidCallback onClose;
  final bool compact;

  @override
  State<ChatbotPanel> createState() => _ChatbotPanelState();
}

class _ChatbotPanelState extends State<ChatbotPanel> {
  static const List<String> _suggestions = [
    '¿Qué incidencias hay cerca?',
    'Bloqueos en La Paz',
    'Alertas de combustible',
    'Sobreprecios en El Alto',
    'Incidencias graves',
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // Controlador compartido: el historial sobrevive al cerrar/reabrir el panel.
  final ChatbotController _bot = ChatbotController.shared;

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isTranscribing = false;

  final FlutterTts _tts = FlutterTts();
  int? _speakingIndex;

  @override
  void initState() {
    super.initState();
    _bot.addListener(_handleBotUpdate);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speakingIndex = null);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _speakingIndex = null);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  /// Lee en voz alta la respuesta (toca de nuevo para detener).
  Future<void> _speak(String text, int index) async {
    if (_speakingIndex == index) {
      await _tts.stop();
      if (mounted) setState(() => _speakingIndex = null);
      return;
    }
    await _tts.stop();
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.5);
    if (mounted) setState(() => _speakingIndex = index);
    await _tts.speak(text);
  }

  void _handleBotUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _bot.removeListener(_handleBotUpdate);
    // OJO: no se hace _bot.dispose() porque es la instancia compartida.
    _tts.stop();
    _recorder.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _send([String? value]) async {
    final text = (value ?? _controller.text).trim();
    if (text.isEmpty || _bot.isSending) return;
    if (_isRecording) {
      await _recorder.stop();
      if (mounted) setState(() => _isRecording = false);
    }
    _controller.clear();
    _bot.send(text);
  }

  /// Graba voz y la transcribe con Whisper (OpenAI) vía el backend.
  Future<void> _toggleVoice() async {
    if (_isTranscribing) return;

    if (_isRecording) {
      final path = await _recorder.stop();
      if (mounted) setState(() => _isRecording = false);
      if (path == null) return;
      await _transcribe(path);
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _snack('Se necesita permiso de micrófono para dictar');
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/mapia_chatbot_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    if (mounted) setState(() => _isRecording = true);
  }

  Future<void> _transcribe(String path) async {
    setState(() => _isTranscribing = true);
    try {
      final text = await _bot.transcribe(path);
      if (!mounted) return;
      if (text.isEmpty) {
        _snack('No se entendió el audio, intenta de nuevo');
      } else {
        setState(() {
          _controller.text = text;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      }
    } catch (_) {
      _snack('No se pudo transcribir el audio');
    } finally {
      if (mounted) setState(() => _isTranscribing = false);
    }
  }

  void _openIncidentOnMap(AlertMapItem incident) {
    final navigator = Navigator.of(context);
    widget.onClose();
    navigator.pushNamed(
      '/map',
      arguments: {
        'alertId': incident.id,
        'lat': incident.latitude,
        'lng': incident.longitude,
      },
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
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
              child: ListenableBuilder(
                listenable: _bot,
                builder: (context, _) {
                  final messages = _bot.messages;
                  final itemCount = messages.length + (_bot.isSending ? 1 : 0);
                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    itemCount: itemCount,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index >= messages.length) {
                        return const _TypingBubble();
                      }
                      return _MessageBubble(
                        message: messages[index],
                        onIncidentTap: _openIncidentOnMap,
                        isSpeaking: _speakingIndex == index,
                        onSpeak: () => _speak(messages[index].text, index),
                      );
                    },
                  );
                },
              ),
            ),
            _SuggestionChips(suggestions: _suggestions, onSelected: _send),
            ListenableBuilder(
              listenable: _bot,
              builder: (context, _) => _ChatInput(
                controller: _controller,
                onSend: _send,
                onMic: _toggleVoice,
                isRecording: _isRecording,
                isTranscribing: _isTranscribing,
                enabled: !_bot.isSending,
              ),
            ),
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
                  'Pregúntame por las incidencias registradas',
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
  const _MessageBubble({
    required this.message,
    required this.onIncidentTap,
    required this.onSpeak,
    required this.isSpeaking,
  });

  final ChatMessage message;
  final ValueChanged<AlertMapItem> onIncidentTap;
  final VoidCallback onSpeak;
  final bool isSpeaking;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Column(
      crossAxisAlignment: isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
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
                border: isUser
                    ? null
                    : Border.all(color: const Color(0xFFE1E7DE)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
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
        ),
        if (!isUser && message.text.trim().isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onSpeak,
              icon: Icon(
                isSpeaking
                    ? Icons.stop_circle_rounded
                    : Icons.volume_up_rounded,
                size: 18,
              ),
              label: Text(isSpeaking ? 'Detener' : 'Escuchar'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                foregroundColor: AppTheme.primaryBlue,
              ),
            ),
          ),
        if (message.incidents.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final incident in message.incidents)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _IncidentCard(
                incident: incident,
                onTap: () => onIncidentTap(incident),
              ),
            ),
        ],
      ],
    );
  }
}

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({required this.incident, required this.onTap});

  final AlertMapItem incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final place =
        incident.zone ?? incident.municipality ?? incident.department ?? '—';
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFE1E7DE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(top: 4, right: 9),
                  decoration: BoxDecoration(
                    color: severityColor(incident.severity),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textNavy,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${incident.alertType.label} · ${incident.severity.label} · $place',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.mutedText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppTheme.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7F4),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: const Color(0xFFE1E7DE)),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
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
  const _ChatInput({
    required this.controller,
    required this.onSend,
    required this.onMic,
    this.isRecording = false,
    this.isTranscribing = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String?> onSend;
  final VoidCallback onMic;
  final bool isRecording;
  final bool isTranscribing;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hint = isRecording
        ? 'Grabando… toca el micrófono para terminar'
        : isTranscribing
        ? 'Transcribiendo…'
        : 'Escribe tu mensaje';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled && !isTranscribing,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: const Icon(Icons.chat_bubble_outline_rounded),
                  suffixIcon: _MicButton(
                    isRecording: isRecording,
                    isTranscribing: isTranscribing,
                    onPressed: onMic,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
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
                onPressed: enabled ? () => onSend(null) : null,
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

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.isRecording,
    required this.isTranscribing,
    required this.onPressed,
  });

  final bool isRecording;
  final bool isTranscribing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isTranscribing) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return IconButton(
      tooltip: isRecording ? 'Detener grabación' : 'Dictar con voz',
      onPressed: onPressed,
      icon: Icon(
        isRecording ? Icons.stop_circle_rounded : Icons.mic_none_rounded,
        color: isRecording ? AppTheme.boliviaRed : AppTheme.mutedText,
      ),
    );
  }
}
