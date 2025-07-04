import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

void showSnackbar(final BuildContext context, final String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: LightColors.primary,
      content: Center(
        child: Text(
          message,
          style: TextStyle(
            color: white,
          ),
        ),
      ),
      width: 300.0,
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
  );
}
