import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class CustomLabelSelector extends StatelessWidget {
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final String? selectedValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomLabelSelector({
    super.key,
    required this.label,
    required this.hintText,
    required this.validator,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        spacing: 8.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? DarkColors.textPrimary : null,
            ),
          ),
          DropdownButtonFormField<String>(
            initialValue: selectedValue,
            hint: Text(
              hintText,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? DarkColors.textSecondary : Colors.grey[400],
              ),
            ),
            dropdownColor: isDark ? DarkColors.surface : white,
            style: TextStyle(color: isDark ? DarkColors.textPrimary : null),
            items: items.map((final String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(
                  color: isDark ? DarkColors.border : Colors.grey.shade400,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(
                  color: isDark ? DarkColors.border : Colors.grey.shade400,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(
                  color: isDark ? DarkColors.primary : LightColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: isDark ? DarkColors.surface : white,
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: isDark ? DarkColors.textSecondary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
