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
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(
        top: 20.0,
        left: 50.0,
        right: 50.0,
        bottom: 20.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
      ),
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
          SizedBox(height: 10.0),
          Expanded(
            child: Container(
              color: white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 30.0,
              ),
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}
