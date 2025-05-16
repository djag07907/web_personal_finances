import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/login/bloc/login_bloc.dart';
import 'package:web_personal_finances/login/bloc/login_event.dart';
import 'package:web_personal_finances/login/bloc/login_state.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginButtonPressed(BuildContext context) {
    context.read<LoginBloc>().add(LoginSubmitted(
          email: _emailController.text,
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => LoginBloc(
        authRepository: RepositoryProvider.of<AuthRepository>(
          context,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Login Failed: ${state.error}',
                    ),
                  ),
                );
              }
              if (state is LoginSuccess) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 20),
                  if (state is LoginLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: () => _onLoginButtonPressed(context),
                      child: const Text('Login'),
                    ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text("Don't have an account? Register"),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
