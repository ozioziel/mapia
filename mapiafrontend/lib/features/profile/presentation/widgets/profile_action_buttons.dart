import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({
    super.key,
    required this.onEdit,
    required this.onLanguage,
    required this.onLogout,
    this.isBusy = false,
  });

  final VoidCallback onEdit;
  final VoidCallback onLanguage;
  final VoidCallback onLogout;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: isBusy ? null : onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: Text(context.l10n.editProfile),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: isBusy ? null : onLanguage,
          icon: const Icon(Icons.language_rounded),
          label: Text(context.l10n.language),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: isBusy ? null : onLogout,
          icon: const Icon(Icons.logout_rounded),
          label: Text(context.l10n.logout),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFE53935),
            minimumSize: const Size.fromHeight(46),
            side: const BorderSide(color: Color(0xFFE53935)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
