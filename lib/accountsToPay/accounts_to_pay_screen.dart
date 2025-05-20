import 'package:flutter/material.dart';
import 'package:web_personal_finances/accountsToPay/widget/accounts_to_pay_body.dart';

class AccountsToPayScreen extends StatelessWidget {
  const AccountsToPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AccountsToPayBody(),
    );
  }
}
