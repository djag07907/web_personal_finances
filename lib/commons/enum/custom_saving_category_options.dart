import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';

enum CustomSavingCategoryOptions {
  emergencyFund,
  vacation,
  vehicle,
  realEstate,
  education,
  retirement,
  investment,
  tech,
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
      case CustomSavingCategoryOptions.emergencyFund:
        return translate('saving_cat_emergency_fund');
      case CustomSavingCategoryOptions.vacation:
        return translate('saving_cat_vacation');
      case CustomSavingCategoryOptions.vehicle:
        return translate('saving_cat_vehicle');
      case CustomSavingCategoryOptions.realEstate:
        return translate('saving_cat_real_estate');
      case CustomSavingCategoryOptions.education:
        return translate('saving_cat_education');
      case CustomSavingCategoryOptions.retirement:
        return translate('saving_cat_retirement');
      case CustomSavingCategoryOptions.investment:
        return translate('saving_cat_investment');
      case CustomSavingCategoryOptions.tech:
        return translate('saving_cat_tech');
      case CustomSavingCategoryOptions.health:
        return translate('saving_cat_health');
      case CustomSavingCategoryOptions.other:
        return translate('saving_cat_other');
    }
  }

  IconData get icon {
    switch (this) {
      case CustomSavingCategoryOptions.emergencyFund:
        return Icons.health_and_safety_outlined;
      case CustomSavingCategoryOptions.vacation:
        return Icons.flight_takeoff_outlined;
      case CustomSavingCategoryOptions.vehicle:
        return Icons.directions_car_outlined;
      case CustomSavingCategoryOptions.realEstate:
        return Icons.home_work_outlined;
      case CustomSavingCategoryOptions.education:
        return Icons.school_outlined;
      case CustomSavingCategoryOptions.retirement:
        return Icons.beach_access_outlined;
      case CustomSavingCategoryOptions.investment:
        return Icons.trending_up_outlined;
      case CustomSavingCategoryOptions.tech:
        return Icons.devices_outlined;
      case CustomSavingCategoryOptions.health:
        return Icons.favorite_outline;
      case CustomSavingCategoryOptions.other:
        return Icons.savings_outlined;
    }
  }
}
