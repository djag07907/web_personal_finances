import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/home/bloc/home_bloc.dart';
import 'package:web_personal_finances/home/bloc/home_event.dart';
import 'package:web_personal_finances/home/widget/home_body.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (final BuildContext ctx) {
        final String uid =
            FirebaseAuth.instance.currentUser?.uid ?? emptyString;
        return HomeBloc(userRepository: ctx.read<UserRepository>())
          ..add(HomeFetchProfile(uid: uid));
      },
      child: const HomeBody(),
    );
  }
}
