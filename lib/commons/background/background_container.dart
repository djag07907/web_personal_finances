import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer({super.key});

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: darkBackgroundColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            darkBackgroundColor,
            grayDarkBackground,
            darkBackgroundColor,
          ],
        ),
      ),
    );
  }
}
