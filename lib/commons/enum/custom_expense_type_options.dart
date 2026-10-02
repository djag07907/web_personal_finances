import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';

enum CustomExpenseTypeOptions {
  fixed,
  variable;

  String toTranslate(final BuildContext context) {
    final String Function(
      String key, {
      List<String>? args,
      Map<String, dynamic>? namedArgs,
      int? pluralValue,
      String? translationContext,
    })
    translate = context.translate;
    switch (this) {
      case CustomExpenseTypeOptions.fixed:
        return translate('fixed');
      case CustomExpenseTypeOptions.variable:
        return translate('variable');
    }
  }

  IconData get icon {
    switch (this) {
      case CustomExpenseTypeOptions.fixed:
        return Icons.lock_outline;
      case CustomExpenseTypeOptions.variable:
        return Icons.tune_outlined;
    }
  }
}
