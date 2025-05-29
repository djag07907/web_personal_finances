import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';
import 'package:web_personal_finances/resources/themes.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height: 50.0,
                margin: EdgeInsets.only(top: 10.0),
                width: MediaQuery.of(context).size.width * 0.45,
                decoration: BoxDecoration(
                  color: lightTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(300.0),
                    bottomLeft: Radius.circular(300.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Welcome to your personal finances, {username}',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontSize: fontSize24,
                          color: white,
                        ),
                  ),
                ),
              ),
            ),
            //TODO: Review what to add here
            // Text(
            //   'Welcome',
            //   style: Theme.of(context).textTheme.displayLarge!.copyWith(
            //       fontWeight: FontWeight.w600,
            //       color: white,
            //       fontSize: fontSize20),
            // ),
            // Text(
            //   'loremipsum',
            //   style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            //         fontWeight: FontWeight.w400,
            //         color: white,
            //         fontSize: fontSize16,
            //       ),
            // ),
            Expanded(
              child: CustomCardBody(
                isMain: true,
                title: context.translate('home'),
                body: Column(
                  children: [],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
