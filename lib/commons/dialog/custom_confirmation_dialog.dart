import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:lottie/lottie.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class CustomConfirmationDialog {
  static void showCustomConfirmationDialog(
    final BuildContext context, {
    required final String confirmationText,
    required final void Function()? onPrimaryButtonTap,
    final void Function()? onSecondaryButtonTap,
  }) {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return Dialog(
          clipBehavior: Clip.none,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                20.0,
              ),
              color: LightColors.background,
            ),
            width: 440.0,
            height: 415.0,
            constraints: BoxConstraints(
              maxWidth: 550.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 25.0,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 250,
                  height: 250,
                  child: Lottie.asset(
                    'assets/animations/alert_animation.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                  ),
                ),
                Text(
                  confirmationText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: greyHard,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      width: 180.0,
                      height: 45.0,
                      child: CustomButton(
                        isPrimary: false,
                        text: context.translate('cancel'),
                        onPressed: () {
                          if (onSecondaryButtonTap != null) {
                            onSecondaryButtonTap();
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 180.0,
                      height: 45.0,
                      child: CustomButton(
                        isPrimary: true,
                        text: context.translate('accept'),
                        onPressed: () {
                          if (onPrimaryButtonTap != null) {
                            onPrimaryButtonTap();
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
