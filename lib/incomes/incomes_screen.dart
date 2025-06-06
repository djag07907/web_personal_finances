import 'package:flutter/material.dart';
import 'package:web_personal_finances/incomes/widget/incomes_body.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class IncomesScreen extends StatelessWidget {
  const IncomesScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: transparent,
      body: IncomesBody(),
    );
  }
}
