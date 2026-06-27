import 'package:flutter/material.dart';
import 'package:mapiafrontend/features/reports/data/analyzed_report.dart';

class DynamicOptionalFieldsWidget extends StatelessWidget {
  const DynamicOptionalFieldsWidget({
    super.key,
    required this.fields,
    required this.controllers,
    required this.values,
    required this.onValueChanged,
  });

  final List<AnalyzedField> fields;
  final Map<String, TextEditingController> controllers;
  final Map<String, String?> values;
  final void Function(String key, String? value) onValueChanged;

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) {
      return const Text(
        'Esta categoría no necesita datos extra.',
        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
      );
    }

    return Column(
      children: [
        for (final field in fields)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OptionalFieldInput(
              field: field,
              controller: controllers[field.key],
              value: values[field.key],
              onChanged: (value) => onValueChanged(field.key, value),
            ),
          ),
      ],
    );
  }
}

class _OptionalFieldInput extends StatelessWidget {
  const _OptionalFieldInput({
    required this.field,
    required this.controller,
    required this.value,
    required this.onChanged,
  });

  final AnalyzedField field;
  final TextEditingController? controller;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case 'select':
        return DropdownButtonFormField<String>(
          initialValue: field.options.contains(value) ? value : null,
          decoration: InputDecoration(
            labelText: field.label,
            helperText: field.hint,
          ),
          items: field.options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: onChanged,
        );
      case 'bool':
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(field.label),
          subtitle: field.hint == null ? null : Text(field.hint!),
          value: value == 'true',
          onChanged: (enabled) => onChanged(enabled ? 'true' : 'false'),
        );
      default:
        final isNumber = field.type == 'number';
        final isTextArea = field.type == 'textarea';
        return TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          minLines: isTextArea ? 2 : 1,
          maxLines: isTextArea ? 4 : 1,
          decoration: InputDecoration(
            labelText: field.label,
            helperText: field.hint,
            suffixIcon: field.detectedByAi
                ? const Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: Color(0xFF22C55E),
                  )
                : null,
          ),
        );
    }
  }
}
