import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final bool? isAdd;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.isPrimary,
    this.isAdd,
    this.fontSize,
    this.padding,
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
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
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
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize ?? ((isAdd ?? false) ? fontSize14 : fontSize15),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
