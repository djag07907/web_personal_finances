import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class CustomLabelInput extends StatelessWidget {
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isCalendar;
  final bool isReadOnly;
  final VoidCallback? onTap;

  CustomLabelInput({
    super.key,
    required this.label,
    required this.hintText,
    required this.validator,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.isCalendar = false,
    this.isReadOnly = false,
    this.onTap,
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
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            readOnly: isReadOnly,
            onTap: isCalendar ? onTap : null,
            style: TextStyle(color: isDark ? DarkColors.textPrimary : null),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark ? DarkColors.textSecondary : null,
              ),
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
              suffixIcon: isCalendar
                  ? Icon(
                      Icons.calendar_month,
                      color: isDark ? DarkColors.textSecondary : null,
                    )
                  : null,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
