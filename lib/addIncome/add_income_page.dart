import 'package:flutter/material.dart';
import 'package:web_personal_finances/addIncome/widget/add_income_body.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';

class AddIncomePage extends StatelessWidget {
  final IncomeItem? incomeItem;
  final bool isEdit;
  final void Function(IncomeItem) onSave;
  final VoidCallback onClose;

  const AddIncomePage({
    super.key,
    this.incomeItem,
    this.isEdit = false,
    required this.onSave,
    required this.onClose,
  });

  @override
  Widget build(final BuildContext context) {
    return AddIncomeBody(
      incomeItem: incomeItem,
      isEdit: isEdit,
      onSave: onSave,
      onClose: onClose,
    );
  }
}
