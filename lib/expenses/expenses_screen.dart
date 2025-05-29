import 'package:flutter/material.dart';
import 'package:web_personal_finances/expenses/widget/expenses_body.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: transparent,
      body: ExpensesBody(),
    );
  }
}
