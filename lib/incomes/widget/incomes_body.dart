import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';

class IncomesBody extends StatefulWidget {
  const IncomesBody({super.key});

  @override
  State<IncomesBody> createState() => _IncomesBodyState();
}

class _IncomesBodyState extends State<IncomesBody> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomCardBody(
          isMain: false,
          isMenu: true,
          title: context.translate('incomes'),
          body: Column(
            children: [],
          ),
        ),
      ],
    );
  }
}
