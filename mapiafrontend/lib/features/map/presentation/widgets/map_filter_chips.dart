import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/map/domain/models/map_filter_model.dart';

class MapFilterChips extends StatelessWidget {
  const MapFilterChips({
    super.key,
    required this.filters,
    required this.availableCategories,
    required this.onToggle,
    required this.onClear,
  });

  final MapLayerFilters filters;
  final Set<MapFilterCategory> availableCategories;
  final ValueChanged<MapFilterCategory> onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    const categories = MapFilterCategory.values;

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: categories.length + (filters.isEmpty ? 0 : 1),
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (!filters.isEmpty && index == 0) {
            return _MapFilterChip(
              label: 'Todo',
              icon: Icons.close_rounded,
              selected: false,
              enabled: true,
              onTap: onClear,
            );
          }

          final category = categories[index - (filters.isEmpty ? 0 : 1)];
          final enabled = availableCategories.contains(category);
          return _MapFilterChip(
            label: category.label,
            icon: category.icon,
            selected: filters.activeCategories.contains(category),
            enabled: enabled,
            onTap: enabled ? () => onToggle(category) : null,
          );
        },
      ),
    );
  }
}

class _MapFilterChip extends StatelessWidget {
  const _MapFilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : const Color(0xFF0F172A);
    final background = selected
        ? AppTheme.primaryBlue
        : Colors.white.withValues(alpha: enabled ? 0.96 : 0.72);

    return Tooltip(
      message: enabled ? label : '$label sin datos disponibles',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(999),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? AppTheme.primaryBlue
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: enabled ? foreground : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: enabled ? foreground : const Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
