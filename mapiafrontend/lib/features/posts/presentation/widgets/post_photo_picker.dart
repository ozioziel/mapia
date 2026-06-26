import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';

class PostPhotoPicker extends StatelessWidget {
  const PostPhotoPicker({
    super.key,
    required this.imageSource,
    required this.onSelectSource,
  });

  final String? imageSource;
  final ValueChanged<String> onSelectSource;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onSelectSource(l10n.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.takePhoto, overflow: TextOverflow.ellipsis),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppTheme.softBorder),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onSelectSource(l10n.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  l10n.chooseFromGallery,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppTheme.softBorder),
                ),
              ),
            ),
          ],
        ),
        if (imageSource != null) ...[
          const SizedBox(height: 10),
          Container(
            height: 96,
            decoration: BoxDecoration(
              gradient: AppTheme.mintGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.softBorder),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.image_outlined, color: Color(0xFF0B8063)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.photoSelectedFrom(imageSource!),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
