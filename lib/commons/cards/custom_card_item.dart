import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class CustomCardItem extends StatelessWidget {
  final IconData? leadingIcon;
  final String? leadingSvg;
  final String titleText;
  final String subtitleText;

  const CustomCardItem({
    super.key,
    this.leadingIcon,
    this.leadingSvg,
    required this.titleText,
    required this.subtitleText,
  });

  @override
  Widget build(final BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Responsive breakpoints
    final bool isExtraSmall = screenWidth < 600;
    final bool isSmall = screenWidth >= 600 && screenWidth < 900;
    // final bool isMedium = screenWidth >= 900 && screenWidth < 1200;
    // final bool isLarge = screenWidth >= 1200;

    // Adaptive sizing
    final double iconSize = isExtraSmall ? 16 : (isSmall ? 18 : 20);
    final double iconPadding = isExtraSmall ? 6 : (isSmall ? 8 : 10);
    final double horizontalMargin = isExtraSmall ? 8 : (isSmall ? 12 : 16);
    final double cardMargin = isExtraSmall ? 4 : (isSmall ? 6 : 8);
    final double borderRadius = isExtraSmall ? 12 : (isSmall ? 16 : 20);

    return Flexible(
      fit: FlexFit.tight,
      child: Container(
        constraints: BoxConstraints(
          minHeight: isExtraSmall ? 70 : 80,
          maxHeight: isExtraSmall ? 90 : 110,
        ),
        margin: EdgeInsets.all(cardMargin),
        child: Card(
          elevation: 2,
          color: isDark ? DarkColors.surface : white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: isDark ? DarkColors.border : LightColors.primary,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalMargin,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Icon container
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: isDark ? DarkColors.primary : LightColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Builder(
                    builder: (final BuildContext context) {
                      if (leadingSvg != null) {
                        return SvgPicture.asset(
                          leadingSvg!,
                          width: iconSize,
                          height: iconSize,
                        );
                      } else if (leadingIcon != null) {
                        return Icon(leadingIcon, color: white, size: iconSize);
                      }
                      return Icon(
                        Icons.warning_amber_outlined,
                        color: LightColors.accent,
                        size: iconSize,
                      );
                    },
                  ),
                ),
                SizedBox(width: horizontalMargin),
                // Text content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        titleText,
                        maxLines: isExtraSmall ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: isExtraSmall ? 12 : (isSmall ? 13 : 14),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                          fontSize: isExtraSmall ? 11 : (isSmall ? 12 : 13),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
