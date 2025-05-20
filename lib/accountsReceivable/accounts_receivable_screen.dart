import 'package:flutter/material.dart';
import 'package:web_personal_finances/accountsReceivable/widget/accounts_receivable_body.dart';

class AccountsReceivableScreen extends StatelessWidget {
  const AccountsReceivableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AccountsReceivableBody(),
    );
  }
}
