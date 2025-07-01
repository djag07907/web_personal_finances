import 'package:flutter/material.dart';
import 'package:web_personal_finances/addAccountToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/addAccountToPay/widget/add_account_to_pay_body.dart';

class AddAccountToPayScreen extends StatelessWidget {
  final AccountToPayItem? accountToPayItem;
  final bool isEdit;
  final void Function(AccountToPayItem) onSave;
  final VoidCallback onClose;

  const AddAccountToPayScreen({
    super.key,
    this.accountToPayItem,
    this.isEdit = false,
    required this.onSave,
    required this.onClose,
  });

  @override
  Widget build(final BuildContext context) {
    return AddAccountToPayBody(
      accountToPayItem: accountToPayItem,
      isEdit: isEdit,
      onSave: onSave,
      onClose: onClose,
    );
  }
}
