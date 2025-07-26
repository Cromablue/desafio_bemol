import 'package:flutter/material.dart';
import '../../../models/supported_codes.dart';

class CurrencySelectorFormField extends StatelessWidget {
  final String label;
  final String value;
  final List<SupportedCode> supportedCodes;
  final ValueChanged<String?> onChanged;

  const CurrencySelectorFormField({
    super.key,
    required this.label,
    required this.value,
    required this.supportedCodes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: supportedCodes.map((code) {
        return DropdownMenuItem(
          value: code.code,
          child: Text(
            '${code.code} - ${code.name}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      isExpanded: true,
    );
  }
}