import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(final BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: white.withValues(alpha: 0.6),
      child: Center(
        child: SizedBox(
          width: 150.0,
          child: Lottie.asset(
            '${animationPath}loader.json',
          ),
        ),
      ),
    );
  }
}
