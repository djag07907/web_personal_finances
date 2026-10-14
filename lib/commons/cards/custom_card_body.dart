import 'package:flutter/material.dart';
import 'package:web_personal_finances/commons/header/custom_header.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class CustomCardBody extends StatelessWidget {
  final bool isMenu;
  final String title;
  final Widget body;
  final bool isMain;
  final String? description;
  final String? buttonText;
  final bool? buttonIsPrimary;
  final bool? buttonIsAdd;
  final VoidCallback? onButtonPressed;

  const CustomCardBody({
    super.key,
    this.isMenu = false,
    required this.title,
    required this.body,
    this.isMain = false,
    this.description,
    this.buttonText,
    this.buttonIsPrimary,
    this.buttonIsAdd,
    this.onButtonPressed,
  });

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalMargin = screenWidth < 1300
        ? (screenWidth < 900 ? 12.0 : 20.0)
        : 50.0;
    final double horizontalPadding = screenWidth < 1300
        ? (screenWidth < 900 ? 14.0 : 20.0)
        : 30.0;

    return Container(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(
        top: 20.0,
        left: horizontalMargin,
        right: horizontalMargin,
        bottom: 20.0,
      ),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0)),
      child: Column(
        children: <Widget>[
          Visibility(
            visible: !isMain,
            child: CustomHeader(
              title: title,
              isMenu: isMenu,
              description: description,
              buttonText: buttonText,
              buttonIsPrimary: buttonIsPrimary,
              buttonIsAdd: buttonIsAdd,
              onButtonPressed: onButtonPressed,
            ),
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: Container(
              color: isDark ? DarkColors.surface : white,
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: horizontalPadding,
              ),
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}
