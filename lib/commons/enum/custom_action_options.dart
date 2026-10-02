import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';

enum CustomOptions {
  edit,
  delete,
  activate,
  deactivate,
  markAsReceived,
  markAsPending;

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
      case CustomOptions.edit:
        return translate('edit');
      case CustomOptions.delete:
        return translate('delete');
      case CustomOptions.activate:
        return translate('activate');
      case CustomOptions.deactivate:
        return translate('deactivate');
      case CustomOptions.markAsReceived:
        return translate('mark_as_received');
      case CustomOptions.markAsPending:
        return translate('mark_as_pending');
    }
  }
}
