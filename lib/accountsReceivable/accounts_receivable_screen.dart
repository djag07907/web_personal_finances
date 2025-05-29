import 'package:flutter/material.dart';
import 'package:web_personal_finances/accountsReceivable/widget/accounts_receivable_body.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class AccountsReceivableScreen extends StatelessWidget {
  const AccountsReceivableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: transparent,
      body: AccountsReceivableBody(),
    );
  }
}
