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
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.22,
      height: 80,
      margin: EdgeInsets.all(10.0),
      child: Card(
        elevation: 2,
        color: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: LightColors.primary,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: LightColors.primary,
                shape: BoxShape.circle,
              ),
              child: Builder(
                builder: (final BuildContext context) {
                  if (leadingSvg != null) {
                    return SvgPicture.asset(leadingSvg!);
                  } else if (leadingIcon != null) {
                    return Icon(
                      leadingIcon,
                      color: white,
                      size: 20,
                    );
                  }
                  return Icon(
                    Icons.warning_amber_outlined,
                    color: LightColors.accent,
                    size: 20.0,
                  );
                },
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    titleText,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: LightColors.textPrimary,
                        ),
                  ),
                  Text(
                    subtitleText,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: LightColors.textPrimary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
