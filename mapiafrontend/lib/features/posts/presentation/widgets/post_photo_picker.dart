import 'package:flutter/material.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onSelectSource('Cámara'),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text(
                  'Tomar foto',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onSelectSource('Galería'),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galería', overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
        if (imageSource != null) ...[
          const SizedBox(height: 10),
          Container(
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4F0),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.softBorder),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.image_outlined, color: Color(0xFF0B8063)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Foto seleccionada desde $imageSource',
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
