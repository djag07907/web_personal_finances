import 'package:flutter/material.dart';
import 'package:web_personal_finances/commons/header/custom_header.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class CustomCardBody extends StatelessWidget {
  final bool isMenu;
  final String title;
  final Widget body;
  final bool isMain;

  const CustomCardBody({
    super.key,
    this.isMenu = false,
    required this.title,
    required this.body,
    this.isMain = false,
  });

  @override
  Widget build(final BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(
        top: 20.0,
        left: 50.0,
        right: 50.0,
        bottom: 50.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Column(
        spacing: 10.0,
        children: <Widget>[
          Visibility(
            visible: !isMain,
            child: CustomHeader(
              title: title,
              isMenu: isMenu,
            ),
          ),
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
