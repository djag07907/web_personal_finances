import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomCardBody(
          isMain: false,
          isMenu: true,
          title: context.translate('profile'),
          body: Column(
            children: [],
          ),
        ),
      ],
    );
  }
}
