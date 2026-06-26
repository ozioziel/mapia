import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/features/language/domain/entities/app_language_entity.dart';

class LanguageOptionTile extends StatelessWidget {
  const LanguageOptionTile({
    super.key,
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguageEntity language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(language.name),
      subtitle: Text(_statusLabel(l10n)),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0B8063))
          : const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  String _statusLabel(dynamic l10n) {
    return switch (language.status) {
      AppLanguageStatus.available => l10n.available,
      AppLanguageStatus.partial => l10n.availablePartial,
      AppLanguageStatus.preparing => l10n.translationInPreparation,
    };
  }
}
