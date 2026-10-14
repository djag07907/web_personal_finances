import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';

enum CustomAccountToPayCategoryOptions {
  loan,
  creditCard,
  rentMortgage,
  utilities,
  taxes,
  insurance,
  supplier,
  personalDebt,
  other;

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
      case CustomAccountToPayCategoryOptions.loan:
        return translate('loan');
      case CustomAccountToPayCategoryOptions.creditCard:
        return translate('credit_card');
      case CustomAccountToPayCategoryOptions.rentMortgage:
        return translate('rent_mortgage');
      case CustomAccountToPayCategoryOptions.utilities:
        return translate('utilities');
      case CustomAccountToPayCategoryOptions.taxes:
        return translate('taxes');
      case CustomAccountToPayCategoryOptions.insurance:
        return translate('insurance');
      case CustomAccountToPayCategoryOptions.supplier:
        return translate('supplier');
      case CustomAccountToPayCategoryOptions.personalDebt:
        return translate('personal_debt');
      case CustomAccountToPayCategoryOptions.other:
        return translate('other');
    }
  }

  IconData get icon {
    switch (this) {
      case CustomAccountToPayCategoryOptions.loan:
        return Icons.account_balance_outlined;
      case CustomAccountToPayCategoryOptions.creditCard:
        return Icons.credit_card_outlined;
      case CustomAccountToPayCategoryOptions.rentMortgage:
        return Icons.home_outlined;
      case CustomAccountToPayCategoryOptions.utilities:
        return Icons.bolt_outlined;
      case CustomAccountToPayCategoryOptions.taxes:
        return Icons.receipt_long_outlined;
      case CustomAccountToPayCategoryOptions.insurance:
        return Icons.shield_outlined;
      case CustomAccountToPayCategoryOptions.supplier:
        return Icons.local_shipping_outlined;
      case CustomAccountToPayCategoryOptions.personalDebt:
        return Icons.people_outline;
      case CustomAccountToPayCategoryOptions.other:
        return Icons.category_outlined;
    }
  }
}
