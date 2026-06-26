import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({
    super.key,
    required this.onEdit,
    required this.onVerifyPhone,
    required this.onLanguage,
    required this.onLogout,
    required this.phoneVerified,
    this.isBusy = false,
  });

  final VoidCallback onEdit;
  final VoidCallback onVerifyPhone;
  final VoidCallback onLanguage;
  final VoidCallback onLogout;
  final bool phoneVerified;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: isBusy ? null : onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: Text(context.l10n.editProfile),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.boliviaRed,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isBusy || phoneVerified ? null : onVerifyPhone,
            icon: Icon(
              phoneVerified
                  ? Icons.verified_rounded
                  : Icons.phone_android_outlined,
            ),
            label: Text(
              phoneVerified ? 'Telefono verificado' : 'Verificar telefono',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.boliviaGreen,
              side: const BorderSide(color: AppTheme.boliviaGreen),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isBusy ? null : onLanguage,
            icon: const Icon(Icons.language_rounded),
            label: Text(context.l10n.language),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isBusy ? null : onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: Text(context.l10n.logout),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.boliviaRed,
              side: const BorderSide(color: AppTheme.boliviaRed),
            ),
          ),
        ],
      ),
    );
  }
}
