import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/signUp/bloc/signup_bloc.dart';
import 'package:web_personal_finances/signUp/bloc/signup_event.dart';
import 'package:web_personal_finances/signUp/bloc/signup_state.dart';

class SignUpBody extends StatefulWidget {
  const SignUpBody({super.key});
  @override
  State<SignUpBody> createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<SignUpBody> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUpButtonPressed(BuildContext context) {
    context.read<SignupBloc>().add(SignUpSubmitted(
          email: _emailController.text,
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignupBloc>(
      create: (_) => SignupBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BlocConsumer<SignupBloc, SignupState>(
            listener: (context, state) {
              if (state is SignUpFailure) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Registration Failed: ${state.error}')));
              }
              if (state is SignUpSuccess) {
                // Navigate to home screen or pop back to login
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
                  if (state is SignUpLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: () => _onSignUpButtonPressed(context),
                      child: const Text('SigUp'),
                    ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Already have an account? Login'),
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
