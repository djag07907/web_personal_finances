import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_personal_finances/commons/button/custom_back_button.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final bool isMenu;

  const CustomHeader({
    super.key,
    required this.title,
    this.isMenu = false,
  });

  @override
  Widget build(
    final BuildContext context,
  ) {
    return Container(
      color: white,
      padding: EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: isMenu ? 100.0 : 35.0,
      ),
      child: Row(
        children: <Widget>[
          Visibility(
            visible: !isMenu,
            child: CustomBackButton(
              fnOnPressButton: () => context.pop(),
            ),
          ),
          Expanded(
            child: Text(
              title.toUpperCase(),
              textAlign: isMenu ? TextAlign.center : TextAlign.start,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontSize: fontSize22,
                    color: LightColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
