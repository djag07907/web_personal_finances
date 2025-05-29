import 'package:flutter/material.dart';
import 'package:web_personal_finances/commons/background/background_container.dart';
import 'package:web_personal_finances/commons/layout/layout_not_available.dart';
import 'package:web_personal_finances/menu/widget/menu_body.dart';
import 'package:web_personal_finances/resources/constants.dart';

class MenuScreen extends StatelessWidget {
  final Widget menuBody;

  const MenuScreen({
    super.key,
    required this.menuBody,
  });

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (
          final BuildContext context,
          final BoxConstraints constraints,
        ) {
          return Stack(
            children: <Widget>[
              BackgroundContainer(),
              if (constraints.maxWidth > minDesktopWidth)
                MenuBody(body: menuBody)
              else
                LayoutNotAvailable(),
            ],
          );
        },
      ),
    );
  }
}
