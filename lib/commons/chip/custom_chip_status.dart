import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class CustomChipStatus extends StatelessWidget {
  final bool isActive;
  final Color chipColor;
  final bool isAccount;

  const CustomChipStatus({
    super.key,
    this.isActive = true,
    this.chipColor = primaryColor,
    this.isAccount = false,
  });

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 84,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color:
            (isActive
                    ? chipColor
                    : (isDark
                          ? DarkColors.surfaceLight
                          : LightColors.greyBackground))
                .withValues(alpha: 0.8),
      ),
      child: Text(
        isAccount
            ? context.translate(isActive ? 'current_debt' : 'paid')
            : context.translate(isActive ? 'active' : 'inactive'),
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: isActive
              ? white
              : (isDark ? DarkColors.textSecondary : greyHard),
        ),
      ),
    );
  }
}
