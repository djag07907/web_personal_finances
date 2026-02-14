import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_personal_finances/commons/button/custom_back_button.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final bool isMenu;
  final String? description;
  final String? buttonText;
  final bool? buttonIsPrimary;
  final bool? buttonIsAdd;
  final VoidCallback? onButtonPressed;

  const CustomHeader({
    super.key,
    required this.title,
    this.isMenu = false,
    this.description,
    this.buttonText,
    this.buttonIsPrimary,
    this.buttonIsAdd,
    this.onButtonPressed,
  });

  @override
  Widget build(
    final BuildContext context,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 900;

    return Container(
      color: isDark ? DarkColors.surface : white,
      padding: EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: isMenu ? (isSmallScreen ? 24.0 : 44.0) : 35.0,
      ),
      child: isSmallScreen && (description != null || buttonText != null)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Visibility(
                      visible: !isMenu,
                      child: CustomBackButton(
                        fnOnPressButton: () => context.pop(),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .copyWith(
                                  fontSize: fontSize22,
                                  color: LightColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (description != null) ...<Widget>[
                            SizedBox(height: 4),
                            Text(
                              description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (buttonText != null && onButtonPressed != null) ...<Widget>[
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 140,
                      height: 36,
                      child: CustomButton(
                        text: buttonText!,
                        isPrimary: buttonIsPrimary ?? true,
                        isAdd: buttonIsAdd ?? false,
                        onPressed: onButtonPressed!,
                      ),
                    ),
                  ),
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Back button
                Visibility(
                  visible: !isMenu,
                  child: CustomBackButton(
                    fnOnPressButton: () => context.pop(),
                  ),
                ),
                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title.toUpperCase(),
                        textAlign: TextAlign.start,
                        style:
                            Theme.of(context).textTheme.headlineLarge!.copyWith(
                                  fontSize: fontSize22,
                                  color: LightColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (description != null) ...<Widget>[
                        SizedBox(height: 4),
                        Text(
                          description!,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? DarkColors.textSecondary
                                : LightColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Button
                if (buttonText != null && onButtonPressed != null) ...<Widget>[
                  SizedBox(width: 16),
                  SizedBox(
                    width: 140,
                    height: 36,
                    child: CustomButton(
                      text: buttonText!,
                      isPrimary: buttonIsPrimary ?? true,
                      isAdd: buttonIsAdd ?? true,
                      onPressed: onButtonPressed!,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
