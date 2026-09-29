import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class CustomBackButton extends StatelessWidget {
  final void Function()? fnOnPressButton;

  const CustomBackButton({super.key, required this.fnOnPressButton});

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      color: isDark ? DarkColors.primary : LightColors.primary,
      onPressed: fnOnPressButton,
      icon: const Icon(size: 25.0, Icons.arrow_back_ios_new),
    );
  }
}
