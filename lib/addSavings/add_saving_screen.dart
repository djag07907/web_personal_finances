import 'package:flutter/material.dart';
import 'package:web_personal_finances/addSavings/widget/add_saving_body.dart';
import 'package:web_personal_finances/savings/model/saving_item.dart';

class AddSavingScreen extends StatelessWidget {
  final SavingItem? savingItem;
  final bool isEdit;
  final void Function(SavingItem) onSave;
  final VoidCallback onClose;

  const AddSavingScreen({
    super.key,
    this.savingItem,
    this.isEdit = false,
    required this.onSave,
    required this.onClose,
  });

  @override
  Widget build(final BuildContext context) {
    return AddSavingBody(
      savingItem: savingItem,
      isEdit: isEdit,
      onSave: onSave,
      onClose: onClose,
    );
  }
}
