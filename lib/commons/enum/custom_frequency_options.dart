import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';

enum CustomFrequencyOptions {
  once,
  daily,
  weekly,
  biweekly,
  monthly,
  yearly;

  String toTranslate(
    final BuildContext context,
  ) {
    final String Function(
      String key, {
      List<String>? args,
      Map<String, dynamic>? namedArgs,
      int? pluralValue,
      String? translationContext,
    }) translate = context.translate;
    switch (this) {
      case CustomFrequencyOptions.once:
        return translate('once');
      case CustomFrequencyOptions.daily:
        return translate('daily');
      case CustomFrequencyOptions.weekly:
        return translate('weekly');
      case CustomFrequencyOptions.biweekly:
        return translate('biweekly');
      case CustomFrequencyOptions.monthly:
        return translate('monthly');
      case CustomFrequencyOptions.yearly:
        return translate('yearly');
    }
  }
}
