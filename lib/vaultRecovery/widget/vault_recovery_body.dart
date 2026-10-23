import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/commons/bloc/app_auth_notifier.dart';
import 'package:web_personal_finances/commons/security/file_picker_helper.dart';
import 'package:web_personal_finances/commons/security/recovery_key_utils.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/vaultRecovery/bloc/vault_recovery_bloc.dart';
import 'package:web_personal_finances/vaultRecovery/bloc/vault_recovery_event.dart';
import 'package:web_personal_finances/vaultRecovery/bloc/vault_recovery_state.dart';

class VaultRecoveryBody extends StatefulWidget {
  const VaultRecoveryBody({super.key});

  @override
  State<VaultRecoveryBody> createState() => _VaultRecoveryBodyState();
}

class _VaultRecoveryBodyState extends State<VaultRecoveryBody> {
  final TextEditingController _recoveryPhraseController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _localError;
  bool _keyFileLoaded = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _recoveryPhraseController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleUploadKeyFile() async {
    try {
      final String? content = await pickTextFile();
      if (content == null || content.isEmpty) return;

      final String? phrase = RecoveryKeyUtils.extractRecoveryPhrase(content);
      if (phrase != null) {
        setState(() {
          _recoveryPhraseController.text = phrase;
          _keyFileLoaded = true;
          _localError = null;
        });
      } else {
        setState(() {
          _localError =
              'Could not find a valid 12-word recovery key in the chosen file.';
        });
      }
    } catch (_) {
      setState(() {
        _localError = 'Failed to read emergency key file.';
      });
    }
  }

  void _handleRestoreAndUnlock() {
    setState(() => _localError = null);

    final String rawPhrase = _recoveryPhraseController.text.trim();
    final String? phrase = RecoveryKeyUtils.extractRecoveryPhrase(rawPhrase);
    final List<String> words = phrase != null
        ? phrase.split(' ').where((final String w) => w.isNotEmpty).toList()
        : <String>[];

    // Form input validation logic ON THE BODY
    if (words.length != 12) {
      setState(() {
        _localError =
            'Please upload a valid .txt recovery file or paste all 12 recovery words.';
      });
      return;
    }

    final String password =
        SessionVault.instance.pendingAuthPassword ??
        _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _localError =
            'Please enter your current account password to re-encrypt your vault.';
      });
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String uid = currentUser?.uid ?? '';
    final String email = currentUser?.email ?? '';

    if (uid.isEmpty) {
      setState(() {
        _localError = 'Session expired. Please sign in again.';
      });
      return;
    }

    context.read<VaultRecoveryBloc>().add(
      VaultRecoveryUnlockSubmitted(
        uid: uid,
        email: email,
        recoveryPhrase: phrase!,
        password: password,
      ),
    );
  }

  Future<void> _handleConfirmResetVault() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (final BuildContext ctx) {
        return AlertDialog(
          title: const Text('Reset Encrypted Vault?'),
          content: const Text(
            'WARNING: If you have permanently lost your Emergency Key, resetting your vault will create a brand new vault. '
            'Past encrypted records (such as encrypted income entries) cannot be recovered without the original key.\n\n'
            'Do you wish to proceed with creating a fresh vault?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: unhealthyRed,
                foregroundColor: white,
              ),
              child: const Text('Reset & Start Fresh'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final String password =
        SessionVault.instance.pendingAuthPassword ??
        _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _localError =
            'Please enter your current login password below to create your fresh vault.';
      });
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String uid = currentUser?.uid ?? emptyString;
    final String email = currentUser?.email ?? emptyString;

    if (uid.isEmpty) {
      setState(() {
        _localError = 'Session expired. Please sign in again.';
      });
      return;
    }

    if (mounted) {
      context.read<VaultRecoveryBloc>().add(
        VaultRecoveryResetSubmitted(uid: uid, email: email, password: password),
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String email = currentUser?.email ?? 'Your Account';
    final bool needsPassword =
        SessionVault.instance.pendingAuthPassword == null;

    return BlocConsumer<VaultRecoveryBloc, VaultRecoveryState>(
      listener: (final BuildContext ctx, final VaultRecoveryState state) async {
        // Response state conditions ON THE BODY
        if (state is VaultRecoverySuccess) {
          RecoveryKeyUtils.downloadEmergencyKey(
            email: email,
            uid: currentUser?.uid ?? '',
            recoveryPhrase: state.recoveryPhrase,
          );
          showSnackbar(
            ctx,
            'Vault unlocked & re-encrypted with your new password!',
          );
          await ctx.read<AppAuthNotifier>().refreshProfile();
        } else if (state is VaultRecoveryResetSuccess) {
          RecoveryKeyUtils.downloadEmergencyKey(
            email: email,
            uid: currentUser?.uid ?? '',
            recoveryPhrase: state.recoveryPhrase,
          );
          showSnackbar(
            ctx,
            'Fresh vault created! Downloaded new emergency key.',
          );
          await ctx.read<AppAuthNotifier>().refreshProfile();
        }
      },
      builder: (final BuildContext ctx, final VaultRecoveryState state) {
        final bool isRecovering = state is VaultRecoveryInProgress;
        final bool isResetting = state is VaultRecoveryResetInProgress;
        final String? displayedError = state is VaultRecoveryFailure
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
                      width: 1,
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
                      // Top Lock Icon & Header
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
                                Icons.lock_rounded,
                                color: LightColors.primary,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Zero-Knowledge Vault Locked',
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
                              'Password was recently reset for $email',
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

                      // Explanatory Box
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
                                'Because your financial records are secured with Zero-Knowledge encryption, '
                                'changing your password does not expose your data. '
                                'Provide your Emergency Key below to re-encrypt and restore access to your records.',
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

                      // Upload Key File Dropzone
                      InkWell(
                        onTap: isRecovering || isResetting
                            ? null
                            : _handleUploadKeyFile,
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
                              color: _keyFileLoaded
                                  ? healthyGreen
                                  : LightColors.primary.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                _keyFileLoaded
                                    ? Icons.check_circle_rounded
                                    : Icons.upload_file_rounded,
                                color: _keyFileLoaded
                                    ? healthyGreen
                                    : LightColors.primary,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _keyFileLoaded
                                    ? 'Emergency Key Loaded Successfully!'
                                    : 'Upload Emergency Key File (.txt)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _keyFileLoaded
                                      ? healthyGreen
                                      : LightColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _keyFileLoaded
                                    ? 'Click "Restore & Unlock Vault" below to continue'
                                    : 'Select your downloaded pecunia_emergency_key.txt file',
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

                      // 12-Word Phrase Field
                      Text(
                        '12-Word Recovery Phrase',
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
                        controller: _recoveryPhraseController,
                        enabled: !isRecovering && !isResetting,
                        maxLines: 2,
                        style: TextStyle(
                          color: isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Paste 12 words or key file text here...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? DarkColors.textSecondary
                                : Colors.grey.shade400,
                            fontSize: 12.5,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? DarkColors.background
                              : Colors.grey.shade50,
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

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
                          enabled: !isRecovering && !isResetting,
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            color: isDark
                                ? DarkColors.textPrimary
                                : LightColors.textPrimary,
                            fontSize: 13.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your new login password',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? DarkColors.textSecondary
                                  : Colors.grey.shade400,
                              fontSize: 13,
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

                      // Primary Unlock Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isRecovering || isResetting
                              ? null
                              : _handleRestoreAndUnlock,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LightColors.primary,
                            foregroundColor: white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: isRecovering
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: white,
                                  ),
                                )
                              : const Icon(Icons.lock_open_rounded, size: 20),
                          label: Text(
                            isRecovering
                                ? 'Unlocking & Re-encrypting Vault...'
                                : 'Restore & Unlock Vault',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bottom Secondary Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextButton.icon(
                            onPressed: isRecovering || isResetting
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
                          TextButton.icon(
                            onPressed: isRecovering || isResetting
                                ? null
                                : _handleConfirmResetVault,
                            icon: const Icon(
                              Icons.delete_forever_outlined,
                              size: 16,
                              color: unhealthyRed,
                            ),
                            label: Text(
                              isResetting
                                  ? 'Resetting...'
                                  : 'Lost Key? Reset Vault',
                              style: const TextStyle(
                                fontSize: 13,
                                color: unhealthyRed,
                              ),
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
        );
      },
    );
  }
}
