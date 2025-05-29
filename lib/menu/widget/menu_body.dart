import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:go_router/go_router.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/image/circle_image_border.dart';
import 'package:flutter_side_menu/src/data/side_menu_builder_data.dart';
import 'package:web_personal_finances/menu/model/menu_model.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';
import 'package:web_personal_finances/routes/landing_routes.dart';

part 'side_menu.dart';

class MenuBody extends StatelessWidget {
  final Widget body;

  const MenuBody({
    super.key,
    required this.body,
  });

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Row(
            children: <Widget>[
              SideMenuWidget(),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    body,
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
