import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:internationalization/internationalization.dart';
import 'package:lottie/lottie.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor =
        isDark ? DarkColors.textPrimary : LightColors.textPrimary;

    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: BlocListener<SignupBloc, SignupState>(
            listener: (final BuildContext context, final SignupState state) {
              if (state is SignUpError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: redAlert,
                    content: Text('Registration Failed: ${state.error}'),
                  ),
                );
              }
              if (state is SignUpSuccess) {
                context.go(homeRoute);
              }
            },
            child: LayoutBuilder(
              builder: (
                final BuildContext context,
                final BoxConstraints constraints,
              ) {
                return Row(
                  children: <Widget>[
                    if (constraints.maxWidth >= 800)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Lottie.asset(
                            'assets/animations/finance_animation2.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Card(
                              color: white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      context.translate('create_your_account'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 20),
                                    TextField(
                                      controller: _emailController,
                                      decoration: _buildInputDecoration(
                                        context.translate('email'),
                                        Icons.email_outlined,
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(color: textColor),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: _buildInputDecoration(
                                        context.translate('password'),
                                        Icons.lock_outline,
                                        isPasswordField: true,
                                      ),
                                      style: TextStyle(color: textColor),
                                    ),
                                    const SizedBox(height: 24),
                                    if (context.read<SignupBloc>().state
                                        is SignUpInProgress)
                                      const CircularProgressIndicator()
                                    else
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _onSignUpButtonPressed,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            backgroundColor:
                                                LightColors.primary,
                                            foregroundColor: white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            context.translate('sign_up'),
                                            style:
                                                const TextStyle(fontSize: 16),
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
                                      child: Text(
                                        context
                                            .translate('already_have_account'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        BlocBuilder<SignupBloc, SignupState>(
          builder: (final BuildContext context, final SignupState state) {
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
    final String label,
    final IconData icon, {
    final bool isPasswordField = false,
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
