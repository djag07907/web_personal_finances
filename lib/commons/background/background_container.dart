import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/constants.dart';

class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer({super.key});

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('${imagePath}home_background.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
