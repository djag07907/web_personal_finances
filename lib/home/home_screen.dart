import 'package:flutter/material.dart';
import 'package:web_personal_finances/home/widget/home_body.dart';
import 'package:web_personal_finances/menu/menu.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/themes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightTheme.primaryColor,
        iconTheme: IconThemeData(
          color: white,
        ),
      ),
      drawer: Menu(
        userInitials: 'DA',
      ),
      body: HomeBody(),
    );
  }
}
