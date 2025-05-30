import 'package:flutter/material.dart';

void showSnackbar(final BuildContext context, final String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16.0),
    ),
  );
}
