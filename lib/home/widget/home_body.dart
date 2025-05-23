import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';
import 'package:web_personal_finances/resources/themes.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: LightColors.greyBackground,
            //TODO: Add background image
            // image: DecorationImage(
            //   image: AssetImage(
            //     '${imagePath}background.png',
            //   ),
            //   fit: BoxFit.cover,
            // ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            height: 200.0,
            margin: EdgeInsets.only(bottom: 150.0),
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: lightTheme.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(300.0),
                bottomLeft: Radius.circular(300.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Personal finances',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontSize: fontSize40,
                        color: white,
                      ),
                ),
                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: white,
                      ),
                ),
                Text(
                  'loremipsum',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: white,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
