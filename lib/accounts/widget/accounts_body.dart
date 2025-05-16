import 'package:flutter/material.dart';

class AccountsBody extends StatefulWidget {
  const AccountsBody({super.key});

  @override
  State<AccountsBody> createState() => _AccountsBodyState();
}

class _AccountsBodyState extends State<AccountsBody> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Accounts'),
    );
  }
}
