import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final bool? isAdd;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.isPrimary,
    this.isAdd,
    required this.onPressed,
  });

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: isPrimary
            ? white
            : (isDark ? DarkColors.primary : LightColors.primary),
        backgroundColor: isPrimary
            ? (isDark ? DarkColors.primary : LightColors.primary)
            : (isDark ? DarkColors.surface : white),
        shape: RoundedRectangleBorder(
          borderRadius: (isAdd ?? false)
              ? BorderRadius.circular(8.0)
              : BorderRadius.circular(20.0),
          side: BorderSide(
            color: isDark ? DarkColors.primary : LightColors.primary,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: (isAdd ?? false) ? fontSize14 : fontSize18),
      ),
    );
  }
}
