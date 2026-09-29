import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/onboarding/bloc/onboarding_bloc.dart';
import 'package:web_personal_finances/onboarding/widget/onboarding_body.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (final BuildContext context) =>
          OnboardingBloc(userRepository: context.read<UserRepository>()),
      child: const OnboardingBody(),
    );
  }
}
