import 'package:flutter/material.dart';
import 'package:web_personal_finances/commons/layout/layout_not_available.dart';
import 'package:web_personal_finances/menu/widget/menu_body.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
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
      backgroundColor: transparent,
      body: LayoutBuilder(
        builder: (
          final BuildContext context,
          final BoxConstraints constraints,
        ) {
          if (constraints.maxWidth > minDesktopWidth) {
            return MenuBody(
              body: menuBody,
            );
          }
          return LayoutNotAvailable();
        },
      ),
    );
  }
}
