import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';

class AccountsReceivableBody extends StatefulWidget {
  const AccountsReceivableBody({super.key});

  @override
  State<AccountsReceivableBody> createState() => _AccountsReceivableBodyState();
}

class _AccountsReceivableBodyState extends State<AccountsReceivableBody> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomCardBody(
          isMain: false,
          isMenu: true,
          title: context.translate('accounts_receivable'),
          body: Column(
            children: [],
          ),
        ),
      ],
    );
  }
}
