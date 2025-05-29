import 'package:flutter/material.dart';
import 'package:web_personal_finances/accountsToPay/widget/accounts_to_pay_body.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class AccountsToPayScreen extends StatelessWidget {
  const AccountsToPayScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: transparent,
      body: AccountsToPayBody(),
    );
  }
}
