import 'package:flutter/material.dart';
import 'package:web_personal_finances/home/widget/home_body.dart';
import 'package:web_personal_finances/menu/menu.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isClosed = false;

  void _toggleMenu() {
    setState(() {
      _isClosed = !_isClosed;
    });
  }

  void _closeMenu() {
    if (!_isClosed) {
      setState(() {
        _isClosed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.greyBackground,
      body: GestureDetector(
        onTap: _closeMenu,
        child: Row(
          children: [
            GestureDetector(
              onTap: _toggleMenu,
              child: Menu(
                userInitials: 'DA',
                isClosed: _isClosed,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _closeMenu,
                child: HomeBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
