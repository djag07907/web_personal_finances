import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:internationalization/internationalization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_personal_finances/login/bloc/login_bloc.dart';
import 'package:web_personal_finances/login/bloc/login_event.dart';
import 'package:web_personal_finances/login/bloc/login_state.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/routes/landing_routes.dart';
import 'package:lottie/lottie.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});
  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final LoginBloc _loginBloc;
  bool _rememberUser = false;

  @override
  void initState() {
    super.initState();
    _loginBloc = context.read<LoginBloc>();
    _loadRememberedEmail();
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
    final Color welcomeTextColor =
        isDark ? DarkColors.textPrimary : LightColors.textPrimary;

    return Stack(
      children: <Widget>[
        Scaffold(
          body: BlocListener<LoginBloc, LoginState>(
            listener: (final BuildContext context, final LoginState state) {
              if (state is LoginError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: redAlert,
                    content: Text('Login Failed: ${state.error}'),
                  ),
                );
              }
              if (state is LoginSuccess) {
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
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              elevation: 8,
                              color: Theme.of(context).cardColor,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      context.translate('welcome_back'),
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
                                        label: context.translate('email'),
                                        icon: Icons.email_outlined,
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: _buildInputDecoration(
                                        label: context.translate('password'),
                                        icon: Icons.lock_outline,
                                        isPasswordField: true,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: <Widget>[
                                        Checkbox(
                                          value: _rememberUser,
                                          onChanged: (final bool? value) {
                                            setState(() {
                                              _rememberUser = value ?? false;
                                            });
                                          },
                                        ),
                                        Text(
                                          context.translate('remember_me'),
                                          style: TextStyle(
                                            color: LightColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _onLoginButtonPressed,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          backgroundColor: LightColors.primary,
                                          foregroundColor: white,
                                        ),
                                        child: Text(
                                          context.translate('login'),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextButton(
                                      onPressed: () {
                                        context.go(signupRoute);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: LightColors.primary,
                                      ),
                                      child: Text(
                                        context.translate('dont_have_account'),
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
                    if (constraints.maxWidth > 800)
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Lottie.asset(
                            'assets/animations/finance_animation1.json',
                            fit: BoxFit.contain,
                            repeat: true,
                            animate: true,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        BlocBuilder<LoginBloc, LoginState>(
          builder: (final BuildContext context, final LoginState state) {
            if (state is LoginInProgress) {
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

  Future<void> _loadRememberedEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedEmail = prefs.getString('saved_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberUser = true;
      });
    }
  }

  Future<void> _saveRememberedEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberUser) {
      await prefs.setString('saved_email', _emailController.text);
    } else {
      await prefs.remove('saved_email');
    }
  }

  void _onLoginButtonPressed() {
    _saveRememberedEmail();
    _loginBloc.add(
      LoginSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required final String label,
    required final IconData icon,
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
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: LightColors.primary, width: 2),
      ),
    );
  }
}
