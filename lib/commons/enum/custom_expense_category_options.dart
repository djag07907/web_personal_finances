import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';

enum CustomExpenseCategoryOptions {
  housing,
  food,
  transportation,
  subscriptions,
  entertainment,
  health,
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
      case CustomExpenseCategoryOptions.housing:
        return translate('housing');
      case CustomExpenseCategoryOptions.food:
        return translate('food');
      case CustomExpenseCategoryOptions.transportation:
        return translate('transportation');
      case CustomExpenseCategoryOptions.subscriptions:
        return translate('subscriptions');
      case CustomExpenseCategoryOptions.entertainment:
        return translate('entertainment');
      case CustomExpenseCategoryOptions.health:
        return translate('health');
      case CustomExpenseCategoryOptions.other:
        return translate('other');
    }
  }

  IconData get icon {
    switch (this) {
      case CustomExpenseCategoryOptions.housing:
        return Icons.home_outlined;
      case CustomExpenseCategoryOptions.food:
        return Icons.restaurant;
      case CustomExpenseCategoryOptions.transportation:
        return Icons.directions_car_outlined;
      case CustomExpenseCategoryOptions.subscriptions:
        return Icons.subscriptions_outlined;
      case CustomExpenseCategoryOptions.entertainment:
        return Icons.movie_outlined;
      case CustomExpenseCategoryOptions.health:
        return Icons.medical_services_outlined;
      case CustomExpenseCategoryOptions.other:
        return Icons.category_outlined;
    }
  }
}
