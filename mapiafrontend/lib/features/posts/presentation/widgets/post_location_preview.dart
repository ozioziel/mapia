import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';

class PostLocationPreview extends StatelessWidget {
  const PostLocationPreview({
    super.key,
    required this.address,
    required this.onUseCurrentLocation,
  });

  final String address;
  final VoidCallback onUseCurrentLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.softBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFE7F7EF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: Color(0xFF0B8063),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubicación',
                  style: TextStyle(
                    color: AppTheme.textNavy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onUseCurrentLocation,
            child: const Text('Usar'),
          ),
        ],
      ),
    );
  }
}
