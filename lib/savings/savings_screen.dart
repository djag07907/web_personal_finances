import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/savings/widget/savings_body.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: transparent,
      body: SavingsBody(),
    );
  }
}
