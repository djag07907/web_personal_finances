import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/bloc/app_auth_notifier.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/calendar/calendar_widget.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/loader/loader.dart';
import 'package:web_personal_finances/commons/security/bip39_words.dart';
import 'package:web_personal_finances/commons/security/encryption_service.dart';
import 'package:web_personal_finances/commons/security/recovery_key_utils.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';
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
  late final String _recoveryPhrase;
  bool _hasDownloadedKey = false;

  final List<String> _currencies = <String>[
    '$hnlCurrency (L.) - Honduran Lempira',
    '$usdCurrency (\$) - US Dollar',
  ];

  @override
  void initState() {
    super.initState();
    _recoveryPhrase = generateRecoveryPhrase();
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
    } else if (_currentStep == 1) {
      setState(() {
        _currentStep = 2;
      });
    } else {
      if (!_hasDownloadedKey) {
        showSnackbar(
          context,
          'Please download your emergency recovery key to proceed.',
        );
        return;
      }
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

  void _downloadEmergencyKey() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String email = currentUser?.email ?? emptyString;
    final String uid = currentUser?.uid ?? emptyString;

    RecoveryKeyUtils.downloadEmergencyKey(
      email: email,
      uid: uid,
      recoveryPhrase: _recoveryPhrase,
    );

    setState(() {
      _hasDownloadedKey = true;
    });

    showSnackbar(
      context,
      'Recovery key file downloaded. Keep it in a safe location!',
    );
  }

  Future<void> _submitOnboarding() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String uid = currentUser?.uid ?? emptyString;
    final String email = currentUser?.email ?? emptyString;
    final String primaryCode = _selectedCurrencyLabel.contains(usdCurrency)
        ? usdCurrency
        : hnlCurrency;

    final EncryptionService encryptionService = EncryptionService();
    final SecretKey dek = await encryptionService.generateDataEncryptionKey();
    final List<int> salt = encryptionService.generateSalt();
    final String password = SessionVault.instance.pendingAuthPassword ?? uid;

    final Map<String, dynamic> vault = await encryptionService.createVault(
      dek: dek,
      password: password,
      recoveryPhrase: _recoveryPhrase,
      salt: salt,
    );

    SessionVault.instance.setDek(dek);
    SessionVault.instance.setRecoveryPhrase(_recoveryPhrase);

    final UserModel userModel = UserModel(
      uid: uid,
      email: email,
      fullName: _fullNameController.text.trim(),
      profession: _professionController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      primaryCurrency: primaryCode,
      enableDualCurrency: _enableDualCurrency,
      isOnboarded: true,
      vault: vault,
    );

    if (mounted) {
      context.read<OnboardingBloc>().add(
        OnboardingSubmitted(userModel: userModel),
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (final BuildContext context, final OnboardingState state) {
        if (state is OnboardingSuccess) {
          showSnackbar(context, context.translate('income_saved_successfully'));
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
                  constraints: const BoxConstraints(maxWidth: 580),
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
                          'Let\'s set up your profile and security vault to protect your financial data',
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
                              : (_currentStep == 1
                                    ? _buildStepTwo(context, isDark)
                                    : _buildStepThree(context, isDark)),
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
                                    : (_currentStep == 1
                                          ? 'Next: Security Vault'
                                          : 'Complete Setup'),
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
        _buildProgressSegment(
          isDark: isDark,
          title: '1. Profile',
          isActive: _currentStep >= 0,
        ),
        const SizedBox(width: 8),
        _buildProgressSegment(
          isDark: isDark,
          title: '2. Currency',
          isActive: _currentStep >= 1,
        ),
        const SizedBox(width: 8),
        _buildProgressSegment(
          isDark: isDark,
          title: '3. Security',
          isActive: _currentStep >= 2,
        ),
      ],
    );
  }

  Widget _buildProgressSegment({
    required final bool isDark,
    required final String title,
    required final bool isActive,
  }) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isActive
                  ? LightColors.primary
                  : (isDark ? DarkColors.border : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? (isDark ? DarkColors.textPrimary : LightColors.textPrimary)
                  : (isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary),
            ),
          ),
        ],
      ),
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

  Widget _buildStepThree(final BuildContext context, final bool isDark) {
    final List<String> words = _recoveryPhrase.split(' ');

    return Column(
      key: const ValueKey<int>(2),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: LightColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shield_outlined,
            size: 38,
            color: LightColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Zero-Knowledge Security Vault',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Your financial data is encrypted on your device. Download your emergency recovery key below to ensure you can always recover your records.',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? DarkColors.textSecondary
                : LightColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? DarkColors.background.withValues(alpha: 0.6)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? DarkColors.border : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: <Widget>[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List<Widget>.generate(words.length, (
                  final int index,
                ) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? DarkColors.surface : white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? DarkColors.border
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      '${index + 1}. ${words[index]}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _recoveryPhrase));
                    showSnackbar(
                      context,
                      'Recovery phrase copied to clipboard',
                    );
                  },
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text(
                    'Copy Phrase',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: _hasDownloadedKey
              ? 'Download Key Again (.txt)'
              : 'Download Emergency Key (.txt) *',
          onPressed: _downloadEmergencyKey,
          isPrimary: !_hasDownloadedKey,
        ),
        const SizedBox(height: 12),
        if (_hasDownloadedKey)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade400),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Emergency key downloaded! You can now complete setup.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.green.shade300
                          : Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            '⚠️ Downloading your emergency key is required to finish setup',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade700,
            ),
          ),
      ],
    );
  }
}
