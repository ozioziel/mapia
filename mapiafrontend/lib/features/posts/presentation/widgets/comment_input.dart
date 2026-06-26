import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';

class CommentInput extends StatelessWidget {
  const CommentInput({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      minLines: 1,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: context.l10n.writeComment,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.mode_comment_outlined),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.send_rounded),
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
