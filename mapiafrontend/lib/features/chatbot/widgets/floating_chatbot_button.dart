import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/chatbot/widgets/chatbot_panel.dart';

// Experimental frontend-only assistant. Remove this feature folder and the
// wrappers in main.dart to delete the chatbot trial completely.
class FloatingChatbotButton extends StatefulWidget {
  const FloatingChatbotButton({super.key, required this.child});

  final Widget child;

  @override
  State<FloatingChatbotButton> createState() => _FloatingChatbotButtonState();
}

class _FloatingChatbotButtonState extends State<FloatingChatbotButton> {
  bool _isPanelOpen = false;

  void _openChatbot(BuildContext context, bool compact) {
    if (compact) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.78,
            child: ChatbotPanel(
              compact: true,
              onClose: () => Navigator.of(context).pop(),
            ),
          );
        },
      );
      return;
    }

    setState(() => _isPanelOpen = !_isPanelOpen);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final safeBottom = MediaQuery.paddingOf(context).bottom;
        final buttonBottom = compact ? 104.0 + safeBottom : 26.0 + safeBottom;

        return Stack(
          children: [
            widget.child,
            if (!compact && _isPanelOpen)
              Positioned(
                right: 22,
                bottom: 104 + safeBottom,
                child: SizedBox(
                  width: 390,
                  height: 560,
                  child: ChatbotPanel(
                    onClose: () => setState(() => _isPanelOpen = false),
                  ),
                ),
              ),
            Positioned(
              right: 18,
              bottom: buttonBottom,
              child: _ChatBubbleButton(
                isOpen: _isPanelOpen,
                onPressed: () => _openChatbot(context, compact),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChatBubbleButton extends StatelessWidget {
  const _ChatBubbleButton({required this.isOpen, required this.onPressed});

  final bool isOpen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Abrir Asistente MAPIA',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE65A52),
                  Color(0xFFFFCC5C),
                  Color(0xFF1B9B73),
                ],
                stops: [0, 0.52, 1],
              ),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.boliviaGreen.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: Icon(
                isOpen
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.chat_bubble_rounded,
                key: ValueKey(isOpen),
                color: Colors.white,
                size: 29,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
