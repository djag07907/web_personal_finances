import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';

enum CustomInterestType {
  flat,
  french;

  String toTranslate(final BuildContext context) {
    switch (this) {
      case CustomInterestType.flat:
        return context.translate('flat_interest');
      case CustomInterestType.french:
        return context.translate('french_amortization');
    }
  }

  String description(final BuildContext context) {
    switch (this) {
      case CustomInterestType.flat:
        return context.translate('flat_interest_desc');
      case CustomInterestType.french:
        return context.translate('french_amortization_desc');
    }
  }
}
