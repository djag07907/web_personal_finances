import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';

enum CustomIncomeCategoryOptions {
  salary,
  freelance,
  investments,
  rental,
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
      case CustomIncomeCategoryOptions.salary:
        return translate('salary');
      case CustomIncomeCategoryOptions.freelance:
        return translate('freelance');
      case CustomIncomeCategoryOptions.investments:
        return translate('investments');
      case CustomIncomeCategoryOptions.rental:
        return translate('rental');
      case CustomIncomeCategoryOptions.other:
        return translate('other');
    }
  }

  IconData get icon {
    switch (this) {
      case CustomIncomeCategoryOptions.salary:
        return Icons.work_outline;
      case CustomIncomeCategoryOptions.freelance:
        return Icons.laptop_mac;
      case CustomIncomeCategoryOptions.investments:
        return Icons.show_chart;
      case CustomIncomeCategoryOptions.rental:
        return Icons.home_work_outlined;
      case CustomIncomeCategoryOptions.other:
        return Icons.category_outlined;
    }
  }
}
