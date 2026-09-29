import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/resources/constants.dart';
// import 'package:lottie/lottie.dart'; // Commented for now
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
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  late final SignupBloc _signupBloc;

  @override
  void initState() {
    super.initState();
    _signupBloc = context.read<SignupBloc>();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
              builder:
                  (
                    final BuildContext context,
                    final BoxConstraints constraints,
                  ) {
                    return Row(
                      children: <Widget>[
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
                                      _buildLogo(),
                                      const SizedBox(height: 32),
                                      _buildHeader(context, isDark),
                                      const SizedBox(height: 32),
                                      _buildFullNameField(context, isDark),
                                      const SizedBox(height: 20),
                                      _buildEmailField(context, isDark),
                                      const SizedBox(height: 20),
                                      _buildPasswordField(context, isDark),
                                      const SizedBox(height: 20),
                                      _buildConfirmPasswordField(
                                        context,
                                        isDark,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTermsCheckbox(context, isDark),
                                      const SizedBox(height: 24),
                                      _buildSignUpButton(context),
                                      const SizedBox(height: 24),
                                      _buildLoginLink(context, isDark),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (constraints.maxWidth > 800)
                          Expanded(flex: 4, child: _buildRightPanel(isDark)),
                      ],
                    );
                  },
            ),
          ),
        ),
        BlocBuilder<SignupBloc, SignupState>(
          buildWhen: (final SignupState previous, final SignupState current) {
            return (previous is SignUpInProgress) !=
                (current is SignUpInProgress);
          },
          builder: (final BuildContext context, final SignupState state) {
            if (state is SignUpInProgress) {
              return Container(
                color: black.withValues(alpha: 0.5),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _onSignUpButtonPressed() {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: redAlert,
          content: Text('Please accept the Terms and Conditions'),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: redAlert,
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    _signupBloc.add(
      SignUpSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

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
          context.translate('create_your_account'),
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: isDark ? white : LightColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start managing your finances smartly today.',
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

  Widget _buildFullNameField(final BuildContext context, final bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Full Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[200] : LightColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _fullNameController,
          style: TextStyle(color: isDark ? white : LightColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. John Doe',
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
            hintText: 'e.g. john@example.com',
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
        Text(
          context.translate('password'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[200] : LightColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: isDark ? white : LightColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Min. 8 characters',
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

  Widget _buildConfirmPasswordField(
    final BuildContext context,
    final bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[200] : LightColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          style: TextStyle(color: isDark ? white : LightColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Re-enter password',
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
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: isDark ? Colors.grey[400] : LightColors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(final BuildContext context, final bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 20,
          width: 20,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: (final bool? value) {
              setState(() {
                _acceptedTerms = value ?? false;
              });
            },
            activeColor: LightColors.primary,
            side: BorderSide(
              color: isDark ? Color(0xFF2A3632) : Color(0xFFDEE3E1),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            children: <Widget>[
              Text(
                'I agree to the ',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : LightColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () {
                  // TODO: Show terms
                },
                child: Text(
                  'Terms of Service',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: LightColors.primary,
                  ),
                ),
              ),
              Text(
                ' and ',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : LightColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () {
                  // TODO: Show privacy policy
                },
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: LightColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(final BuildContext context) {
    return ElevatedButton(
      onPressed: _onSignUpButtonPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: LightColors.primary,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        shadowColor: LightColors.primary.withValues(alpha: 0.3),
      ),
      child: Text(
        context.translate('sign_up'),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildLoginLink(final BuildContext context, final bool isDark) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Already have an account? ',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : LightColors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () {
              context.go(loginRoute);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Log in',
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 120,
              color: LightColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 48),
            Text(
              'Track. Save. Grow.',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? white : LightColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Join over 50,000 users who are taking control of their financial future with Pecunia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // Commented Lottie animation:
    // return Container(
    //   decoration: BoxDecoration(
    //     gradient: LinearGradient(
    //       begin: Alignment.topLeft,
    //       end: Alignment.bottomRight,
    //       colors: isDark
    //           ? <Color>[
    //               Color(0xFF151d1a),
    //               Color(0xFF1e2825),
    //             ]
    //           : <Color>[
    //               LightColors.primary.withValues(alpha: 0.05),
    //               LightColors.primary.withValues(alpha: 0.1),
    //             ],
    //     ),
    //   ),
    //   child: Center(
    //     child: Lottie.asset(
    //       'assets/animations/finance_animation2.json',
    //       fit: BoxFit.contain,
    //     ),
    //   ),
    // );
  }
}
