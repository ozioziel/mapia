import 'package:flutter/material.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('¿Qué está pasando?'),
        TextField(
          onChanged: provider.updateTitle,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'Ej: Pollo barato cerca de la plaza',
            prefixIcon: Icon(Icons.title_rounded),
          ),
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Cuéntanos más'),
        TextField(
          onChanged: provider.updateDescription,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Describe la novedad de forma corta y útil.',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Tipo de publicación'),
        PostTypeSelector(
          selectedType: provider.selectedType,
          onSelected: provider.selectType,
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Foto opcional'),
        PostPhotoPicker(
          imageSource: provider.imageSource,
          onSelectSource: provider.selectImageSource,
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Ubicación'),
        PostLocationPreview(
          address: provider.address,
          onUseCurrentLocation: provider.useCurrentLocation,
        ),
        if (provider.error != null) ...[
          const SizedBox(height: 14),
          Text(
            provider.error!,
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
            label: Text(provider.isLoading ? 'Publicando...' : 'Publicar'),
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
