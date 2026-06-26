import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/localized_post_type.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class PostTypeSelector extends StatelessWidget {
  const PostTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  final PostType selectedType;
  final ValueChanged<PostType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final type in PostType.values)
          _PostTypeChip(
            type: type,
            selected: selectedType == type,
            onTap: () => onSelected(type),
          ),
      ],
    );
  }
}

class _PostTypeChip extends StatelessWidget {
  const _PostTypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final PostType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final option = type.option;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? option.color.withValues(alpha: 0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? option.color : const Color(0xFFD8DEE8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(option.icon, color: option.color, size: 18),
              const SizedBox(width: 6),
              Text(
                type.label(context),
                style: TextStyle(
                  color: selected ? option.color : const Color(0xFF1F2A44),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
