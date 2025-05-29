import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';

class AccountsToPayBody extends StatefulWidget {
  const AccountsToPayBody({super.key});

  @override
  State<AccountsToPayBody> createState() => _AccountsToPayBodyState();
}

class _AccountsToPayBodyState extends State<AccountsToPayBody> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomCardBody(
          isMain: false,
          isMenu: true,
          title: context.translate('accounts_to_pay'),
          body: Column(
            children: [],
          ),
        ),
      ],
    );
  }
}
