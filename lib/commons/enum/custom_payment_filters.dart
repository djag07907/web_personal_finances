import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';

enum CustomPaymentFilters {
  pending,
  partiallyPaid,
  overdue,
  paid;

  String toTranslate(final BuildContext context) {
    switch (this) {
      case CustomPaymentFilters.pending:
        return context.translate('pending');
      case CustomPaymentFilters.partiallyPaid:
        return context.translate('partially_paid');
      case CustomPaymentFilters.overdue:
        return context.translate('overdue');
      case CustomPaymentFilters.paid:
        return context.translate('paid');
    }
  }
}
