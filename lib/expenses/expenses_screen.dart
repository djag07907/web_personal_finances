import 'package:flutter/material.dart';
import 'package:web_personal_finances/expenses/widget/expenses_body.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExpensesBody(),
    );
  }
}
