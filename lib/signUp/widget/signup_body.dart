import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_personal_finances/routes/landing_routes.dart';
import 'package:web_personal_finances/signUp/bloc/signup_bloc.dart';
import 'package:web_personal_finances/signUp/bloc/signup_event.dart';
import 'package:web_personal_finances/signUp/bloc/signup_state.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class SignUpBody extends StatefulWidget {
  const SignUpBody({super.key});
  @override
  State<SignUpBody> createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<SignUpBody> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final SignupBloc _signupBloc;

  @override
  void initState() {
    super.initState();
    _signupBloc = context.read<SignupBloc>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final welcomeTextColor =
        isDark ? DarkColors.textPrimary : LightColors.textPrimary;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: BlocListener<SignupBloc, SignupState>(
            listener: (context, state) {
              if (state is SignUpError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text('Registration Failed: ${state.error}'),
                  ),
                );
              }
              if (state is SignUpSuccess) {
                context.go(homeRoute);
              }
            },
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      color: white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Create Your Account',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: welcomeTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _emailController,
                              decoration: _buildInputDecoration(
                                'Email',
                                Icons.email_outlined,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              style: isDark
                                  ? const TextStyle(
                                      color: DarkColors.textPrimary,
                                    )
                                  : const TextStyle(
                                      color: LightColors.textPrimary,
                                    ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: _buildInputDecoration(
                                'Password',
                                Icons.lock_outline,
                                isPasswordField: true,
                              ),
                              style: isDark
                                  ? const TextStyle(
                                      color: DarkColors.textPrimary,
                                    )
                                  : const TextStyle(
                                      color: LightColors.textPrimary,
                                    ),
                            ),
                            const SizedBox(height: 24),
                            if (context.read<SignupBloc>().state
                                is SignUpInProgress)
                              const CircularProgressIndicator()
                            else
                              SizedBox(
                                width: 250,
                                child: ElevatedButton(
                                  onPressed: _onSignUpButtonPressed,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    backgroundColor: LightColors.primary,
                                    foregroundColor: white,
                                  ),
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                context.go(loginRoute);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: LightColors.primary,
                              ),
                              child:
                                  const Text('Already have an account? Login'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        BlocBuilder<SignupBloc, SignupState>(
          builder: (context, state) {
            if (state is SignUpInProgress) {
              return Container(
                color: black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _onSignUpButtonPressed() {
    _signupBloc.add(
      SignUpSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon, {
    bool isPasswordField = false,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: LightColors.primary),
      suffixIcon: isPasswordField
          ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: LightColors.primary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade800, width: 2),
      ),
    );
  }
}
