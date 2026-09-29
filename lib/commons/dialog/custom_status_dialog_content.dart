import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/enum/status_dialog_types.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class StatusDialogContent extends StatelessWidget {
  const StatusDialogContent({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.dismissLabel,
    this.onDismiss,
  });

  final StatusDialogType type;
  final String title;
  final String message;
  final String dismissLabel;
  final VoidCallback? onDismiss;

  String get _animationPath {
    switch (type) {
      case StatusDialogType.success:
        return successAnimationPath;
      case StatusDialogType.warning:
      case StatusDialogType.error:
        return alertAnimationPath;
    }
  }

  Color get _accentColor {
    switch (type) {
      case StatusDialogType.success:
        return healthyGreen;
      case StatusDialogType.warning:
        return cautionOrange;
      case StatusDialogType.error:
        return unhealthyRed;
    }
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      clipBehavior: Clip.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: transparent,
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? DarkColors.surface : LightColors.background,
          border: isDark
              ? Border.all(color: DarkColors.border, width: 1)
              : null,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isDark
                  ? black.withValues(alpha: 0.4)
                  : black.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 160,
                height: 160,
                child: Lottie.asset(
                  _animationPath,
                  fit: BoxFit.contain,
                  repeat: type != StatusDialogType.success,
                  animate: true,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: _accentColor,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? DarkColors.textSecondary : greyHard,
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: CustomButton(
                  isPrimary: true,
                  text: dismissLabel,
                  onPressed: () {
                    onDismiss?.call();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
