import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/profile/bloc/profile_bloc.dart';
import 'package:web_personal_finances/profile/bloc/profile_event.dart';
import 'package:web_personal_finances/profile/widget/profile_body.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final User? authUser = FirebaseAuth.instance.currentUser;
    final String uid = authUser?.uid ?? emptyString;

    return BlocProvider<ProfileBloc>(
      create: (final BuildContext context) =>
          ProfileBloc(userRepository: context.read<UserRepository>())
            ..add(ProfileFetchRequested(uid: uid)),
      child: const Scaffold(backgroundColor: transparent, body: ProfileBody()),
    );
  }
}
