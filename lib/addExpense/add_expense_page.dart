import 'package:flutter/material.dart';
import 'package:web_personal_finances/addExpense/model/expense_item.dart';
import 'package:web_personal_finances/addExpense/widget/add_expense_body.dart';

class AddExpensePage extends StatelessWidget {
  final ExpenseItem? expenseItem;
  final bool isEdit;

  const AddExpensePage({
    super.key,
    this.expenseItem,
    this.isEdit = false,
  });

  @override
  Widget build(final BuildContext context) {
    return AddExpenseBody(
      expenseItem: expenseItem,
      isEdit: isEdit,
    );
  }
}
