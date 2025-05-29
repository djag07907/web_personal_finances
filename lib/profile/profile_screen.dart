import 'package:flutter/material.dart';
import 'package:web_personal_finances/profile/widget/profile_body.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: transparent,
      body: ProfileBody(),
    );
  }
}
