import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';

enum CustomSavingTransactionType {
  deposit,
  withdrawal;

  String toTranslate(final BuildContext context) {
    switch (this) {
      case CustomSavingTransactionType.deposit:
        return context.translate('deposit');
      case CustomSavingTransactionType.withdrawal:
        return context.translate('withdrawal');
    }
  }

  IconData get icon {
    switch (this) {
      case CustomSavingTransactionType.deposit:
        return Icons.arrow_downward_rounded;
      case CustomSavingTransactionType.withdrawal:
        return Icons.arrow_upward_rounded;
    }
  }

  Color get color {
    switch (this) {
      case CustomSavingTransactionType.deposit:
        return Colors.green;
      case CustomSavingTransactionType.withdrawal:
        return Colors.redAccent;
    }
  }
}
