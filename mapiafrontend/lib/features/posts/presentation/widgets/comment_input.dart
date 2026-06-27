import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';

class CommentInput extends StatefulWidget {
  const CommentInput({
    super.key,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final Future<bool> Function(String content) onSubmit;
  final bool isSubmitting;

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSubmitting) return;
    final ok = await widget.onSubmit(text);
    if (ok && mounted) {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      minLines: 1,
      maxLines: 3,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        hintText: context.l10n.writeComment,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.mode_comment_outlined),
        suffixIcon: IconButton(
          onPressed: widget.isSubmitting ? null : _submit,
          icon: widget.isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_rounded),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD8DEE8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD8DEE8)),
        ),
      ),
    );
  }
}
