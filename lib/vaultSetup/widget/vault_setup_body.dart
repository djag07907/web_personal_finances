import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internationalization/internationalization.dart';
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
    showSnackbar(context, context.translate('emergency_key_downloaded'));
  }

  void _handleEnableEncryption() {
    setState(() => _localError = null);

    if (!_hasDownloadedKey) {
      setState(() {
        _localError = context.translate('please_download_key_first');
      });
      return;
    }

    final String password =
        SessionVault.instance.pendingAuthPassword ??
        _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _localError = context.translate('please_enter_password');
      });
      return;
    }

    final String uid = FirebaseAuth.instance.currentUser?.uid ?? emptyString;
    if (uid.isEmpty) {
      setState(() {
        _localError = context.translate('session_expired_sign_in');
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
          showSnackbar(ctx, context.translate('vault_setup_success'));
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
                              context.translate('secure_your_account'),
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
                              context.translate(
                                'enable_zk_encryption_for',
                                namedArgs: <String, String>{'email': email},
                              ),
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
                                context.translate('vault_setup_explanation'),
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
                                    ? context.translate(
                                        'emergency_key_downloaded',
                                      )
                                    : context.translate(
                                        'download_emergency_key',
                                      ),
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
                                    ? context.translate(
                                        'click_enable_encryption_continue',
                                      )
                                    : context.translate(
                                        'required_before_continue',
                                      ),
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
                          context.translate('current_login_password'),
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
                            hintText: context.translate(
                              'enter_password_sign_in',
                            ),
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
                                ? context.translate('enabling_encryption')
                                : context.translate('enable_encryption'),
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
                          label: Text(
                            context.translate('logout'),
                            style: const TextStyle(fontSize: 13),
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
