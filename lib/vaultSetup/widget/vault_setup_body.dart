import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/commons/bloc/app_auth_notifier.dart';
import 'package:web_personal_finances/commons/security/bip39_words.dart';
import 'package:web_personal_finances/commons/security/recovery_key_utils.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/vaultSetup/bloc/vault_setup_bloc.dart';
import 'package:web_personal_finances/vaultSetup/bloc/vault_setup_event.dart';
import 'package:web_personal_finances/vaultSetup/bloc/vault_setup_state.dart';

class VaultSetupBody extends StatefulWidget {
  const VaultSetupBody({super.key});

  @override
  State<VaultSetupBody> createState() => _VaultSetupBodyState();
}

class _VaultSetupBodyState extends State<VaultSetupBody> {
  final TextEditingController _passwordController = TextEditingController();
  late final String _recoveryPhrase;

  String? _localError;
  bool _hasDownloadedKey = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _recoveryPhrase = generateRecoveryPhrase();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _downloadEmergencyKey() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    RecoveryKeyUtils.downloadEmergencyKey(
      email: currentUser?.email ?? emptyString,
      uid: currentUser?.uid ?? emptyString,
      recoveryPhrase: _recoveryPhrase,
    );
    setState(() {
      _hasDownloadedKey = true;
      _localError = null;
    });
    showSnackbar(
      context,
      'Recovery key file downloaded. Keep it in a safe location!',
    );
  }

  void _handleEnableEncryption() {
    setState(() => _localError = null);

    if (!_hasDownloadedKey) {
      setState(() {
        _localError =
            'Please download your emergency recovery key before continuing.';
      });
      return;
    }

    final String password =
        SessionVault.instance.pendingAuthPassword ??
        _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _localError = 'Please enter your current account password.';
      });
      return;
    }

    final String uid = FirebaseAuth.instance.currentUser?.uid ?? emptyString;
    if (uid.isEmpty) {
      setState(() {
        _localError = 'Session expired. Please sign in again.';
      });
      return;
    }

    context.read<VaultSetupBloc>().add(
      VaultSetupSubmitted(
        uid: uid,
        recoveryPhrase: _recoveryPhrase,
        password: password,
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String email =
        FirebaseAuth.instance.currentUser?.email ?? 'Your Account';
    final bool needsPassword =
        SessionVault.instance.pendingAuthPassword == null;

    return BlocConsumer<VaultSetupBloc, VaultSetupState>(
      listener: (final BuildContext ctx, final VaultSetupState state) async {
        if (state is VaultSetupSuccess) {
          showSnackbar(ctx, 'Zero-Knowledge encryption enabled!');
          await ctx.read<AppAuthNotifier>().refreshProfile();
        }
      },
      builder: (final BuildContext ctx, final VaultSetupState state) {
        final bool isWorking = state is VaultSetupInProgress;
        final String? displayedError = state is VaultSetupFailure
            ? state.error
            : _localError;

        return Scaffold(
          backgroundColor: isDark
              ? DarkColors.background
              : LightColors.background,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? DarkColors.surface : white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? DarkColors.border : Colors.grey.shade300,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: isDark
                            ? black.withValues(alpha: 0.5)
                            : black.withValues(alpha: 0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: LightColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.enhanced_encryption_rounded,
                                color: LightColors.primary,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Secure Your Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? DarkColors.textPrimary
                                    : LightColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Enable Zero-Knowledge encryption for $email',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2824)
                              : LightColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: LightColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Icon(
                              Icons.shield_outlined,
                              color: LightColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your account was created before end-to-end encryption existed. '
                                'Pecunia now protects your financial details so that only you can read them. '
                                'Download your Emergency Key and store it somewhere safe: it is the only way to recover your data if you forget your password.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: isDark
                                      ? DarkColors.textPrimary
                                      : const Color(0xFF1B4D3E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: isWorking ? null : _downloadEmergencyKey,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E2824)
                                : LightColors.primary.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _hasDownloadedKey
                                  ? healthyGreen
                                  : LightColors.primary.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                _hasDownloadedKey
                                    ? Icons.check_circle_rounded
                                    : Icons.download_rounded,
                                color: _hasDownloadedKey
                                    ? healthyGreen
                                    : LightColors.primary,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _hasDownloadedKey
                                    ? 'Emergency Key Downloaded'
                                    : 'Download Emergency Key (.txt)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _hasDownloadedKey
                                      ? healthyGreen
                                      : LightColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _hasDownloadedKey
                                    ? 'Click "Enable Encryption" below to continue'
                                    : 'Required before you can continue',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? DarkColors.textSecondary
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (needsPassword) ...<Widget>[
                        Text(
                          'Current Login Password',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? DarkColors.textPrimary
                                : LightColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          enabled: !isWorking,
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            color: isDark
                                ? DarkColors.textPrimary
                                : LightColors.textPrimary,
                            fontSize: 13.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter the password you use to sign in',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 18,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: isDark
                                ? DarkColors.background
                                : Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                      if (displayedError != null) ...<Widget>[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: unhealthyRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: <Widget>[
                              const Icon(
                                Icons.error_outline_rounded,
                                color: unhealthyRed,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  displayedError,
                                  style: const TextStyle(
                                    color: unhealthyRed,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isWorking ? null : _handleEnableEncryption,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LightColors.primary,
                            foregroundColor: white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: isWorking
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: white,
                                  ),
                                )
                              : const Icon(Icons.lock_rounded, size: 20),
                          label: Text(
                            isWorking
                                ? 'Enabling encryption...'
                                : 'Enable Encryption',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: isWorking
                              ? null
                              : () async {
                                  await context
                                      .read<AuthRepository>()
                                      .signOut();
                                },
                          icon: const Icon(Icons.logout_rounded, size: 16),
                          label: const Text(
                            'Sign Out',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: isDark
                                ? DarkColors.textSecondary
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
