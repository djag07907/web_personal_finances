import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/login/bloc/login_bloc.dart';
import 'package:web_personal_finances/login/widget/login_body.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => LoginBloc(
        authRepository: AuthRepository(),
      ),
      child: const LoginBody(),
    );
  }
}
