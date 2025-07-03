import 'package:flutter/material.dart';
import 'package:web_personal_finances/addIncome/model/income_item.dart';
import 'package:web_personal_finances/addIncome/widget/add_income_body.dart';

class AddIncomeScreen extends StatelessWidget {
  final IncomeItem? incomeItem;
  final bool isEdit;
  final void Function(IncomeItem) onSave;
  final VoidCallback onClose;

  const AddIncomeScreen({
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
