import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/language/domain/entities/app_language_catalog.dart';
import 'package:mapiafrontend/features/language/domain/entities/app_language_entity.dart';
import 'package:mapiafrontend/features/language/presentation/providers/language_provider.dart';
import 'package:mapiafrontend/features/language/presentation/widgets/language_option_tile.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key, required this.provider});

  final LanguageProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        title: Text(l10n.selectLanguage),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textNavy,
        elevation: 0,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: provider,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _LanguageSection(
                  children: [
                    for (final language in AppLanguageCatalog.primaryLanguages)
                      LanguageOptionTile(
                        language: language,
                        selected:
                            provider.locale.languageCode ==
                            language.locale.languageCode,
                        onTap: () => _selectLanguage(context, language),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionTitle(l10n.otherOfficialLanguages),
                const SizedBox(height: 10),
                _LanguageSection(
                  children: [
                    for (final name
                        in AppLanguageCatalog.otherOfficialLanguages)
                      LanguageOptionTile(
                        language: AppLanguageEntity(
                          name: name,
                          locale: const Locale('es'),
                          status: AppLanguageStatus.preparing,
                        ),
                        selected: false,
                        onTap: () => _showPreparingDialog(context, name),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectLanguage(
    BuildContext context,
    AppLanguageEntity language,
  ) async {
    if (!language.canSelect) {
      _showPreparingDialog(context, language.name);
      return;
    }

    await provider.setLocale(language.locale);
    if (context.mounted) Navigator.of(context).pop();
  }

  void _showPreparingDialog(BuildContext context, String languageName) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(languageName),
          content: Text(l10n.languagePreparingMessage(languageName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: Column(children: children),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textNavy,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
