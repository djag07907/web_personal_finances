import 'package:flutter/material.dart';
import 'package:web_personal_finances/addAccountReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/addAccountReceivable/widget/add_account_receivable_body.dart';

class AddAccountReceivableScreen extends StatelessWidget {
  final AccountReceivableItem? accountReceivableItem;
  final bool isEdit;
  final void Function(AccountReceivableItem) onSave;
  final VoidCallback onClose;

  const AddAccountReceivableScreen({
    super.key,
    this.accountReceivableItem,
    this.isEdit = false,
    required this.onSave,
    required this.onClose,
  });

  @override
  Widget build(final BuildContext context) {
    return AddAccountReceivableBody(
      accountReceivableItem: accountReceivableItem,
      isEdit: isEdit,
      onSave: onSave,
      onClose: onClose,
    );
  }
}
