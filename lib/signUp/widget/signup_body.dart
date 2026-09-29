import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/dialog/custom_status_dialog.dart';
import 'package:web_personal_finances/commons/enum/status_dialog_types.dart';
import 'package:web_personal_finances/commons/loader/loader.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/routes/landing_routes.dart';
import 'package:web_personal_finances/signUp/bloc/signup_bloc.dart';
import 'package:web_personal_finances/signUp/bloc/signup_event.dart';
import 'package:web_personal_finances/signUp/bloc/signup_state.dart';

class SignUpBody extends StatefulWidget {
  const SignUpBody({super.key});
  @override
  State<SignUpBody> createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<SignUpBody> {
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
    _emailController.addListener(_updateState);
    _passwordController.addListener(_updateState);
    _confirmPasswordController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateState);
    _passwordController.removeListener(_updateState);
    _confirmPasswordController.removeListener(_updateState);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final String email = _emailController.text.trim();
    final String pass = _passwordController.text;
    final String confirmPass = _confirmPasswordController.text;
    return email.isNotEmpty &&
        email.contains('@') &&
        pass.isNotEmpty &&
        pass.length >= 6 &&
        confirmPass == pass &&
        _acceptedTerms;
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
                CustomStatusDialog.show(
                  context,
                  type: StatusDialogType.error,
                  title: 'Registration Failed',
                  message: state.error,
                  dismissLabel: 'Try Again',
                );
              }
              // SignUpSuccess: router redirect via AppAuthNotifier handles navigation.
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
              return const Loader();
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _onSignUpButtonPressed() {
    if (!_isFormValid) return;

    _signupBloc.add(
      SignUpSubmitted(
        email: _emailController.text.trim(),
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
                color: isDark
                    ? const Color(0xFF2A3632)
                    : const Color(0xFFDEE3E1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF2A3632)
                    : const Color(0xFFDEE3E1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: LightColors.primary,
                width: 2,
              ),
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
            hintText: 'Min. 6 characters',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : LightColors.textSecondary,
            ),
            filled: true,
            fillColor: isDark ? DarkColors.surface : white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF2A3632)
                    : const Color(0xFFDEE3E1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF2A3632)
                    : const Color(0xFFDEE3E1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: LightColors.primary,
                width: 2,
              ),
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
                color: isDark
                    ? const Color(0xFF2A3632)
                    : const Color(0xFFDEE3E1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF2A3632)
                    : const Color(0xFFDEE3E1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: LightColors.primary,
                width: 2,
              ),
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
              color: isDark ? const Color(0xFF2A3632) : const Color(0xFFDEE3E1),
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
                onTap: () {},
                child: const Text(
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
                onTap: () {},
                child: const Text(
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
    final bool valid = _isFormValid;
    return ElevatedButton(
      onPressed: valid ? _onSignUpButtonPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: LightColors.primary,
        disabledBackgroundColor: LightColors.primary.withValues(alpha: 0.3),
        foregroundColor: white,
        disabledForegroundColor: white.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: valid ? 2 : 0,
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
            child: const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
      color: isDark ? DarkColors.surface : LightColors.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 80,
                color: LightColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Take Control of Your Wealth',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? white : LightColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Monitor expenses, manage dual-currency accounts, and reach financial freedom.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
