import 'package:flutter/material.dart';
import 'package:web_personal_finances/commons/dialog/custom_status_dialog_content.dart';
import 'package:web_personal_finances/commons/enum/status_dialog_types.dart';

class CustomStatusDialog {
  const CustomStatusDialog._();

  static Future<void> show(
    final BuildContext context, {
    required final StatusDialogType type,
    required final String title,
    required final String message,
    final String dismissLabel = 'OK',
    final VoidCallback? onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (final BuildContext dialogContext) {
        return StatusDialogContent(
          type: type,
          title: title,
          message: message,
          dismissLabel: dismissLabel,
          onDismiss: onDismiss,
        );
      },
    );
  }
}
