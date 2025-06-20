import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';

enum CustomOptions {
  edit,
  delete,
  activate,
  deactivate;

  String toTranslate(
    final BuildContext context,
  ) {
    final translate = context.translate;
    switch (this) {
      case CustomOptions.edit:
        return translate('edit');
      case CustomOptions.delete:
        return translate('delete');
      case CustomOptions.activate:
        return translate('activate');
      case CustomOptions.deactivate:
        return translate('deactivate');
    }
  }
}
