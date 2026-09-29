import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:internationalization/internationalization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_personal_finances/commons/loader/loader.dart';
import 'package:web_personal_finances/login/bloc/login_bloc.dart';
import 'package:web_personal_finances/login/bloc/login_event.dart';
import 'package:web_personal_finances/login/bloc/login_state.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/routes/landing_routes.dart';
// import 'package:lottie/lottie.dart';

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

    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: isDark
              ? DarkColors.background
              : LightColors.background,
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
              builder:
                  (
                    final BuildContext context,
                    final BoxConstraints constraints,
                  ) {
                    return Row(
                      children: <Widget>[
                        // Left Panel: Login Form
                        Expanded(
                          flex: 5,
                          child: Container(
                            color: isDark ? DarkColors.background : white,
                            child: Center(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 48,
                                ),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 420,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      // Logo
                                      _buildLogo(),
                                      const SizedBox(height: 32),

                                      // Header
                                      _buildHeader(context, isDark),
                                      const SizedBox(height: 32),

                                      // Form Fields
                                      _buildEmailField(context, isDark),
                                      const SizedBox(height: 20),
                                      _buildPasswordField(context, isDark),
                                      const SizedBox(height: 20),

                                      // Remember Me & Forgot Password
                                      _buildRememberAndForgot(context, isDark),
                                      const SizedBox(height: 20),

                                      // Sign In Button
                                      _buildSignInButton(context),
                                      const SizedBox(height: 32),

                                      // Sign Up Link
                                      _buildSignUpLink(context, isDark),
                                      const SizedBox(height: 48),

                                      // Security Indicator
                                      _buildSecurityIndicator(isDark),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Right Panel: Visual
                        if (constraints.maxWidth > 800)
                          Expanded(flex: 4, child: _buildRightPanel(isDark)),
                      ],
                    );
                  },
            ),
          ),
        ),
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (final LoginState previous, final LoginState current) {
            return (previous is LoginInProgress) !=
                (current is LoginInProgress);
          },
          builder: (final BuildContext context, final LoginState state) {
            if (state is LoginInProgress) {
              return const Loader();
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

  // UI Building Methods
  Widget _buildLogo() {
    return Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            pecuniaLogoPath,
            height: 40,
            width: 40,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          appName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(final BuildContext context, final bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.translate('welcome_back'),
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: isDark ? white : LightColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to manage your finances',
          style: TextStyle(
            fontSize: 16,
            color: isDark
                ? DarkColors.textSecondary
                : LightColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(final BuildContext context, final bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.translate('email'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[200] : LightColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: isDark ? white : LightColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'name@example.com',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : LightColors.textSecondary,
            ),
            filled: true,
            fillColor: isDark ? DarkColors.surface : white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Color(0xFF2A3632) : Color(0xFFDEE3E1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Color(0xFF2A3632) : Color(0xFFDEE3E1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: LightColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(final BuildContext context, final bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              context.translate('password'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[200] : LightColors.textPrimary,
              ),
            ),
            Text(
              '0/128',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : LightColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: isDark ? white : LightColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : LightColors.textSecondary,
            ),
            filled: true,
            fillColor: isDark ? DarkColors.surface : white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Color(0xFF2A3632) : Color(0xFFDEE3E1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Color(0xFF2A3632) : Color(0xFFDEE3E1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: LightColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: isDark ? Colors.grey[400] : LightColors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberAndForgot(
    final BuildContext context,
    final bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                value: _rememberUser,
                onChanged: (final bool? value) {
                  setState(() {
                    _rememberUser = value ?? false;
                  });
                },
                activeColor: LightColors.primary,
                side: BorderSide(
                  color: isDark ? Color(0xFF2A3632) : Color(0xFFDEE3E1),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.translate('remember_me'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : LightColors.textPrimary,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // TODO: Implement forgot password
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot password?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: LightColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(final BuildContext context) {
    return ElevatedButton(
      onPressed: _onLoginButtonPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: LightColors.primary,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        shadowColor: LightColors.primary.withValues(alpha: 0.3),
      ),
      child: Text(
        context.translate('login'),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSignUpLink(final BuildContext context, final bool isDark) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Don't have an account? ",
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : LightColors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () {
              context.go(signupRoute);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Sign up',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: LightColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityIndicator(final bool isDark) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.lock, size: 16, color: LightColors.primary),
          const SizedBox(width: 8),
          Text(
            'Your connection is secure',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(final bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? <Color>[Color(0xFF151d1a), Color(0xFF1e2825)]
              : <Color>[
                  LightColors.primary.withValues(alpha: 0.05),
                  LightColors.primary.withValues(alpha: 0.1),
                ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          // Background Pattern (static, no repaint needed)
          Positioned.fill(
            child: RepaintBoundary(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.1,
                child: CustomPaint(painter: _DotPatternPainter()),
              ),
            ),
          ),
          // Lottie Animation (optimized with constraints and performance options)
          Center(
            child: RepaintBoundary(
              // child: ConstrainedBox(
              //   constraints: const BoxConstraints(
              //     maxWidth: 400,
              //     maxHeight: 400,
              //   ),
              //   child: Lottie.asset(
              //     'assets/animations/finance_animation1.json',
              //     fit: BoxFit.contain,
              //     repeat: true,
              //     animate: true,
              //     frameRate: FrameRate.composition,
              //     renderCache: RenderCache.raster,
              //     errorBuilder: (
              //       final BuildContext context,
              //       final Object error,
              //       final StackTrace? stackTrace,
              //     ) {
              //       return Icon(
              //         Icons.account_balance_wallet_outlined,
              //         size: 120,
              //         color: LightColors.primary.withValues(alpha: 0.3),
              //       );
              //     },
              //   ),
              // ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for dot pattern
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(final Canvas canvas, final Size size) {
    final Paint paint = Paint()
      ..color = LightColors.primary
      ..style = PaintingStyle.fill;

    const double spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => false;
}
