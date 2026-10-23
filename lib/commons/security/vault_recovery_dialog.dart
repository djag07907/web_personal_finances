import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/commons/security/encryption_service.dart';
import 'package:web_personal_finances/commons/security/file_picker_helper.dart';
import 'package:web_personal_finances/commons/security/recovery_key_utils.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class VaultRecoveryDialog extends StatefulWidget {
  const VaultRecoveryDialog({super.key, this.onSuccess});

  final VoidCallback? onSuccess;

  static Future<void> show(
    final BuildContext context, {
    final VoidCallback? onSuccess,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (final BuildContext ctx) =>
          VaultRecoveryDialog(onSuccess: onSuccess),
    );
  }

  @override
  State<VaultRecoveryDialog> createState() => _VaultRecoveryDialogState();
}

class _VaultRecoveryDialogState extends State<VaultRecoveryDialog> {
  final TextEditingController _recoveryPhraseController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isRecovering = false;
  String? _errorMessage;
  bool _needsPasswordInput = false;

  @override
  void initState() {
    super.initState();
    _needsPasswordInput = SessionVault.instance.pendingAuthPassword == null;
  }

  @override
  void dispose() {
    _recoveryPhraseController.dispose();
    _newPasswordController.dispose();
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
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage =
              'Could not find a valid 12-word recovery key in the chosen file.';
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Failed to read emergency key file.';
      });
    }
  }

  Future<void> _handleRestoreVault() async {
    final String rawPhrase = _recoveryPhraseController.text.trim();
    final String? phrase = RecoveryKeyUtils.extractRecoveryPhrase(rawPhrase);

    if (phrase == null) {
      setState(() {
        _errorMessage =
            'Please enter or upload a valid 12-word recovery phrase.';
      });
      return;
    }

    final String password =
        SessionVault.instance.pendingAuthPassword ??
        _newPasswordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _needsPasswordInput = true;
        _errorMessage =
            'Please enter your current account password to re-encrypt your vault.';
      });
      return;
    }

    setState(() {
      _isRecovering = true;
      _errorMessage = null;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final String uid = currentUser?.uid ?? emptyString;
      final String email = currentUser?.email ?? emptyString;

      if (uid.isEmpty) {
        setState(() {
          _isRecovering = false;
          _errorMessage = 'Authentication error. Please re-login.';
        });
        return;
      }

      final UserRepository userRepo = context.read<UserRepository>();
      final UserModel? profile = await userRepo.getUser(uid);

      if (profile == null || profile.vault == null) {
        setState(() {
          _isRecovering = false;
          _errorMessage = 'No existing encrypted vault found for this account.';
        });
        return;
      }

      final EncryptionService encryptionService = EncryptionService();
      final SecretKey? dek = await encryptionService
          .unlockVaultWithRecoveryPhrase(profile.vault!, phrase);

      if (dek == null) {
        setState(() {
          _isRecovering = false;
          _errorMessage =
              'Invalid recovery key. The key does not match this account vault.';
        });
        return;
      }

      // Reuse the verified recovery phrase so the user's existing emergency file remains valid
      final List<int> salt = encryptionService.generateSalt();

      final Map<String, dynamic> newVault = await encryptionService.createVault(
        dek: dek,
        password: password,
        recoveryPhrase: phrase,
        salt: salt,
      );

      final UserModel updatedUser = profile.copyWith(vault: newVault);
      await userRepo.saveUser(updatedUser);

      SessionVault.instance.setDek(dek);
      SessionVault.instance.setRecoveryPhrase(phrase);

      // Trigger download of the updated emergency key
      RecoveryKeyUtils.downloadEmergencyKey(
        email: email,
        uid: uid,
        recoveryPhrase: phrase,
      );

      if (mounted) {
        Navigator.of(context).pop();
        showSnackbar(
          context,
          'Vault unlocked & re-encrypted! Downloaded new emergency key.',
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      setState(() {
        _isRecovering = false;
        _errorMessage = 'An error occurred during vault recovery: $e';
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? DarkColors.surface : white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cautionOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lock_clock_rounded,
                      color: cautionOrange,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Encrypted Vault Locked',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? DarkColors.textPrimary
                                : LightColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Password was recently reset or changed',
                          style: TextStyle(
                            fontSize: 13,
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
              const SizedBox(height: 20),

              // Guidance
              Text(
                'Because Zero-Knowledge encryption protects your records, changing your password requires your Emergency Key to re-encrypt and unlock your vault.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Recovery Phrase Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Emergency Recovery Phrase',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _handleUploadKeyFile,
                    icon: const Icon(Icons.upload_file_rounded, size: 16),
                    label: const Text(
                      'Upload Key (.txt)',
                      style: TextStyle(fontSize: 12.5),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: LightColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _recoveryPhraseController,
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
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? DarkColors.border : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? DarkColors.border : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: LightColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_needsPasswordInput) ...<Widget>[
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
                  controller: _newPasswordController,
                  obscureText: true,
                  style: TextStyle(
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your new login password',
                    hintStyle: TextStyle(
                      color: isDark
                          ? DarkColors.textSecondary
                          : Colors.grey.shade400,
                      fontSize: 12.5,
                    ),
                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
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
                      borderSide: BorderSide(
                        color: isDark
                            ? DarkColors.border
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_errorMessage != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: unhealthyRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.error_outline_rounded,
                        color: unhealthyRed,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: unhealthyRed,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isRecovering ? null : _handleRestoreVault,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LightColors.primary,
                      foregroundColor: white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _isRecovering
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: white,
                            ),
                          )
                        : const Icon(Icons.sync_lock_rounded, size: 18),
                    label: Text(
                      _isRecovering
                          ? 'Restoring Vault...'
                          : 'Restore & Sync Vault',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
