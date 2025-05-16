import 'package:flutter/material.dart';
import 'package:web_personal_finances/accounts/widget/accounts_body.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AccountsBody(),
    );
  }
}
