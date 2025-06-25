import 'package:flutter/material.dart';
import 'package:web_personal_finances/addExpense/model/expense_item.dart';
import 'package:web_personal_finances/addExpense/widget/add_expense_body.dart';

class AddExpensePage extends StatelessWidget {
  final ExpenseItem? expenseItem;
  final bool isEdit;
  final void Function(ExpenseItem) onSave;
  final VoidCallback onClose;

  const AddExpensePage({
    super.key,
    this.expenseItem,
    this.isEdit = false,
    required this.onSave,
    required this.onClose,
  });

  @override
  Widget build(final BuildContext context) {
    return AddExpenseBody(
      expenseItem: expenseItem,
      isEdit: isEdit,
      onSave: onSave,
      onClose: onClose,
    );
  }
}
