import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';

enum CustomAccountReceivableCategoryOptions {
  personalLoan,
  clientInvoice,
  sales,
  rental,
  commission,
  promissoryNote,
  refund,
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
      case CustomAccountReceivableCategoryOptions.personalLoan:
        return translate('personal_loan');
      case CustomAccountReceivableCategoryOptions.clientInvoice:
        return translate('client_invoice');
      case CustomAccountReceivableCategoryOptions.sales:
        return translate('sales_goods');
      case CustomAccountReceivableCategoryOptions.rental:
        return translate('rental_receivable');
      case CustomAccountReceivableCategoryOptions.commission:
        return translate('commission_bonus');
      case CustomAccountReceivableCategoryOptions.promissoryNote:
        return translate('promissory_note');
      case CustomAccountReceivableCategoryOptions.refund:
        return translate('refund_deposit');
      case CustomAccountReceivableCategoryOptions.other:
        return translate('other');
    }
  }

  IconData get icon {
    switch (this) {
      case CustomAccountReceivableCategoryOptions.personalLoan:
        return Icons.people_outline;
      case CustomAccountReceivableCategoryOptions.clientInvoice:
        return Icons.business_center_outlined;
      case CustomAccountReceivableCategoryOptions.sales:
        return Icons.point_of_sale_outlined;
      case CustomAccountReceivableCategoryOptions.rental:
        return Icons.apartment_outlined;
      case CustomAccountReceivableCategoryOptions.commission:
        return Icons.card_giftcard_outlined;
      case CustomAccountReceivableCategoryOptions.promissoryNote:
        return Icons.assignment_outlined;
      case CustomAccountReceivableCategoryOptions.refund:
        return Icons.currency_exchange_outlined;
      case CustomAccountReceivableCategoryOptions.other:
        return Icons.category_outlined;
    }
  }
}
