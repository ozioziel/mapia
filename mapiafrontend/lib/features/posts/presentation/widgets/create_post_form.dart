import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/posts/presentation/providers/create_post_provider.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/post_location_preview.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/post_photo_picker.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/post_type_selector.dart';

class CreatePostForm extends StatelessWidget {
  const CreatePostForm({
    super.key,
    required this.provider,
    required this.onSubmit,
  });

  final CreatePostProvider provider;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(l10n.whatIsHappening),
        TextField(
          onChanged: provider.updateTitle,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: l10n.postTitleHint,
            prefixIcon: const Icon(Icons.title_rounded),
          ),
        ),
        const SizedBox(height: 18),
        _SectionTitle(l10n.tellUsMore),
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
        _SectionTitle(l10n.postType),
        PostTypeSelector(
          selectedType: provider.selectedType,
          onSelected: provider.selectType,
        ),
        const SizedBox(height: 18),
        _SectionTitle(l10n.optionalPhoto),
        PostPhotoPicker(
          imageSource: provider.imageSource,
          onSelectSource: provider.selectImageSource,
        ),
        const SizedBox(height: 18),
        _SectionTitle(l10n.location),
        PostLocationPreview(
          address: provider.usesCurrentLocation
              ? l10n.nearCurrentLocation
              : l10n.defaultApproxLocation,
          onUseCurrentLocation: provider.useCurrentLocation,
        ),
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
            onPressed: provider.isLoading ? null : onSubmit,
            icon: provider.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.publish_rounded),
            label: Text(provider.isLoading ? l10n.publishing : l10n.publish),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB300),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textNavy,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
