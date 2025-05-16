import 'package:flutter/material.dart';

class ExpensesBody extends StatefulWidget {
  const ExpensesBody({super.key});

  @override
  State<ExpensesBody> createState() => _ExpensesBodyState();
}

class _ExpensesBodyState extends State<ExpensesBody> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Expenses'),
    );
  }
}
