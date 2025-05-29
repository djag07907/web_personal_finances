import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/constants.dart';

class LayoutNotAvailable extends StatelessWidget {
  const LayoutNotAvailable({super.key});

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Image.asset('${imagePath}logo.jpg'),
    );
  }
}
