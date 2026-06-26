import 'package:flutter/material.dart';

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
                  ? Colors.white
                  : const Color(0xFF1F2A44),
              fontWeight: FontWeight.w900,
            ),
            selectedColor: const Color(0xFF0B8063),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selectedRadiusKm == option
                  ? const Color(0xFF0B8063)
                  : const Color(0xFFD8DEE8),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
      ],
    );
  }
}
