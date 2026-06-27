import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/posts/presentation/providers/create_post_provider.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/event_location_picker.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/post_photo_picker.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/post_type_selector.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';

class CreatePostForm extends StatelessWidget {
  const CreatePostForm({
    super.key,
    required this.provider,
    required this.onSubmit,
    required this.onVerifyPhone,
  });

  final CreatePostProvider provider;
  final VoidCallback onSubmit;
  final VoidCallback onVerifyPhone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(l10n.whatIsHappening),
        TextField(
          onChanged: provider.updateTitle,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: l10n.postTitleHint,
            prefixIcon: const Icon(Icons.title_rounded),
          ),
        ),
        const SizedBox(height: 18),
        SectionLabel(l10n.tellUsMore),
        TextField(
          onChanged: provider.updateDescription,
          minLines: 4,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: l10n.postDescriptionHint,
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 18),
        SectionLabel(l10n.postType),
        PostTypeSelector(
          selectedType: provider.selectedType,
          onSelected: provider.selectType,
        ),
        const SizedBox(height: 18),
        SectionLabel(l10n.optionalPhoto),
        PostPhotoPicker(
          image: provider.image,
          onPick: provider.setImage,
        ),
        const SizedBox(height: 18),
        SectionLabel('Ubicación del evento'),
        EventLocationPicker(
          onChanged: (selection) => provider.setLocation(
            latitude: selection.latitude,
            longitude: selection.longitude,
            address: selection.address,
            radiusMeters: selection.radiusMeters,
          ),
        ),
        if (!provider.phoneVerified && !provider.isCheckingProfile) ...[
          const SizedBox(height: 14),
          _PhoneVerificationWarning(onVerifyPhone: onVerifyPhone),
        ],
        if (provider.hasPhoneVerificationError) ...[
          const SizedBox(height: 14),
          const Text(
            'Debes verificar tu numero de celular antes de publicar.',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (provider.hasValidationError) ...[
          const SizedBox(height: 14),
          Text(
            l10n.completeTitleAndDescription,
            style: const TextStyle(
              color: Color(0xFFE53935),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 22),
        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed:
                provider.isLoading ||
                    provider.isCheckingProfile ||
                    !provider.phoneVerified
                ? null
                : onSubmit,
            icon: provider.isLoading || provider.isCheckingProfile
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.publish_rounded),
            label: Text(
              provider.isLoading || provider.isCheckingProfile
                  ? l10n.publishing
                  : l10n.publish,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.boliviaYellow,
              foregroundColor: AppTheme.textNavy,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneVerificationWarning extends StatelessWidget {
  const _PhoneVerificationWarning({required this.onVerifyPhone});

  final VoidCallback onVerifyPhone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.boliviaYellow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.boliviaYellow.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Debes verificar tu numero de celular antes de publicar.',
            style: TextStyle(
              color: AppTheme.textNavy,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onVerifyPhone,
            icon: const Icon(Icons.phone_android_outlined),
            label: const Text('Verificar celular'),
          ),
        ],
      ),
    );
  }
}
