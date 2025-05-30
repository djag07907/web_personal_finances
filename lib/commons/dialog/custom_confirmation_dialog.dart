import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(
  final BuildContext context,
  final String title,
  final String content,
) {
  return showDialog<bool>(
    context: context,
    builder: (final BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );
}
