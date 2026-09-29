import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/bloc/app_auth_notifier.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/calendar/calendar_widget.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/loader/loader.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/onboarding/bloc/onboarding_bloc.dart';
import 'package:web_personal_finances/onboarding/bloc/onboarding_event.dart';
import 'package:web_personal_finances/onboarding/bloc/onboarding_state.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class OnboardingBody extends StatefulWidget {
  const OnboardingBody({super.key});

  @override
  State<OnboardingBody> createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends State<OnboardingBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  int _currentStep = 0;
  String _selectedCurrencyLabel = '$hnlCurrency (L.) - Honduran Lempira';
  bool _enableDualCurrency = false;

  final List<String> _currencies = <String>[
    '$hnlCurrency (L.) - Honduran Lempira',
    '$usdCurrency (\$) - US Dollar',
  ];

  @override
  void initState() {
    super.initState();
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser?.displayName != null &&
        currentUser!.displayName!.isNotEmpty) {
      _fullNameController.text = currentUser.displayName!;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _professionController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _onNextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
        });
      }
    } else {
      _submitOnboarding();
    }
  }

  void _onPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitOnboarding() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String uid = currentUser?.uid ?? emptyString;
    final String email = currentUser?.email ?? emptyString;
    final String primaryCode = _selectedCurrencyLabel.contains(usdCurrency)
        ? usdCurrency
        : hnlCurrency;

    final UserModel userModel = UserModel(
      uid: uid,
      email: email,
      fullName: _fullNameController.text.trim(),
      profession: _professionController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      primaryCurrency: primaryCode,
      enableDualCurrency: _enableDualCurrency,
      isOnboarded: true,
    );

    context.read<OnboardingBloc>().add(
      OnboardingSubmitted(userModel: userModel),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (final BuildContext context, final OnboardingState state) {
        if (state is OnboardingSuccess) {
          showSnackbar(context, context.translate('income_saved_successfully'));
          // Refresh the notifier so GoRouter's redirect picks up
          // isOnboarded == true and navigates to home automatically.
          context.read<AppAuthNotifier>().refreshProfile();
        } else if (state is OnboardingFailure) {
          showSnackbar(context, state.errorMessage);
        }
      },
      child: Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: isDark
                ? DarkColors.background
                : LightColors.background,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 540),
                  decoration: BoxDecoration(
                    color: isDark ? DarkColors.surface : white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? DarkColors.border : Colors.grey.shade300,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: black.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                pecuniaLogoPath,
                                height: 44,
                                width: 44,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              appName,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? DarkColors.textPrimary
                                    : LightColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome aboard!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? DarkColors.textPrimary
                                : LightColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Let\'s set up your profile preferences to customize your experience',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? DarkColors.textSecondary
                                : LightColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildStepProgress(isDark),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _currentStep == 0
                              ? _buildStepOne(context)
                              : _buildStepTwo(context, isDark),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: <Widget>[
                            if (_currentStep > 0) ...<Widget>[
                              Expanded(
                                child: CustomButton(
                                  onPressed: _onPreviousStep,
                                  isPrimary: false,
                                  text: 'Back',
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: CustomButton(
                                onPressed: _onNextStep,
                                isPrimary: true,
                                text: _currentStep == 0
                                    ? 'Continue'
                                    : 'Complete Setup',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (final BuildContext context, final OnboardingState state) {
              if (state is OnboardingInProgress) {
                return const Loader();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgress(final bool isDark) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: LightColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '1. Profile Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _currentStep >= 1
                      ? LightColors.primary
                      : (isDark ? DarkColors.border : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '2. Currency Setup',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _currentStep >= 1
                      ? (isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary)
                      : (isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepOne(final BuildContext context) {
    return Column(
      key: const ValueKey<int>(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomLabelInput(
          label: 'Full Name *',
          hintText: 'e.g. John Doe',
          validator: (final String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
          controller: _fullNameController,
        ),
        CustomLabelInput(
          label: 'Profession / Title (Optional)',
          hintText: 'e.g. Software Engineer, Designer, Accountant',
          validator: (final String? value) => null,
          controller: _professionController,
        ),
        CustomLabelInput(
          label: 'Birth Date (Optional)',
          hintText: 'Select your date of birth',
          isCalendar: true,
          isReadOnly: true,
          validator: (final String? value) => null,
          controller: _birthDateController,
          onTap: () {
            CustomCalendarDialog().showDateDialog(
              context: context,
              dateController: _birthDateController,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStepTwo(final BuildContext context, final bool isDark) {
    return Column(
      key: const ValueKey<int>(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomLabelSelector(
          label: 'Primary Display Currency *',
          hintText: 'Select primary currency (HNL or USD)',
          validator: (final String? value) {
            if (value == null || value.isEmpty) {
              return 'Please select a primary currency';
            }
            return null;
          },
          selectedValue: _selectedCurrencyLabel,
          items: _currencies,
          onChanged: (final String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCurrencyLabel = newValue;
              });
            }
          },
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark
                ? DarkColors.background.withValues(alpha: 0.5)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? DarkColors.border : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: <Widget>[
              Switch(
                value: _enableDualCurrency,
                activeThumbColor: LightColors.primary,
                onChanged: (final bool value) {
                  setState(() {
                    _enableDualCurrency = value;
                  });
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Enable Dual Currency Mode (HNL & USD)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Allows tracking incomes & expenses simultaneously in both Honduran Lempiras (L.) and US Dollars (\$)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
