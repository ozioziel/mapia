import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';

class AlertRadiusSelector extends StatelessWidget {
  const AlertRadiusSelector({
    super.key,
    required this.optionsKm,
    required this.selectedRadiusKm,
    required this.onSelected,
  });

  final List<double> optionsKm;
  final double selectedRadiusKm;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in optionsKm)
          ChoiceChip(
            label: Text('${option.toStringAsFixed(0)} km'),
            selected: selectedRadiusKm == option,
            onSelected: (_) => onSelected(option),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selectedRadiusKm == option
                  ? AppTheme.textNavy
                  : AppTheme.textNavy,
              fontWeight: FontWeight.w900,
            ),
            selectedColor: AppTheme.boliviaYellow.withValues(alpha: 0.85),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selectedRadiusKm == option
                  ? AppTheme.boliviaYellow
                  : AppTheme.softBorder,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
      ],
    );
  }
}
