import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(final BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: isPrimary ? white : LightColors.primary,
        backgroundColor: isPrimary ? LightColors.primary : white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: LightColors.primary,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize18,
        ),
      ),
    );
  }
}
