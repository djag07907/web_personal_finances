import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/commons/security/file_picker_helper.dart';
import 'package:web_personal_finances/commons/security/recovery_key_utils.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key, this.initialEmail = emptyString});

  final String initialEmail;

  static Future<void> show(
    final BuildContext context, {
    final String initialEmail = emptyString,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (final BuildContext ctx) =>
          ForgotPasswordDialog(initialEmail: initialEmail),
    );
  }

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  late final TextEditingController _emailController;

  bool _isSending = false;
  bool _resetSent = false;
  String? _errorMessage;
  String? _autofillNotice;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleUploadKeyForEmail() async {
    try {
      final String? content = await pickTextFile();
      if (content == null || content.isEmpty) return;

      final String? email = RecoveryKeyUtils.extractEmail(content);
      if (email != null && email.isNotEmpty) {
        setState(() {
          _emailController.text = email;
          _autofillNotice = 'Autofilled account email from emergency key file.';
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage =
              'Could not find an account email in the selected key file.';
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Failed to read emergency key file.';
      });
    }
  }

  Future<void> _handleSendResetEmail() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid account email.';
      });
      return;
    }

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      final AuthRepository authRepo = context.read<AuthRepository>();
      await authRepo.sendPasswordResetEmail(email: email);

      setState(() {
        _isSending = false;
        _resetSent = true;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isSending = false;
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No user account found with this email.';
            break;
          case 'invalid-email':
            _errorMessage = 'The email address format is invalid.';
            break;
          default:
            _errorMessage = 'Failed to send reset email (${e.message}).';
        }
      });
    } catch (_) {
      setState(() {
        _isSending = false;
        _errorMessage = 'An unexpected error occurred. Please try again.';
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
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeader(isDark),
              const SizedBox(height: 18),
              if (!_resetSent)
                _buildFormContent(isDark)
              else
                _buildSuccessContent(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(final bool isDark) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: LightColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: LightColors.primary,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Reset Password',
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
                'Zero-Knowledge Protected Account',
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? DarkColors.textSecondary : Colors.grey.shade600,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildFormContent(final bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Zero-Knowledge Explanatory Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E2824)
                : LightColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
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
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Enter your account email to receive a password reset link. '
                  'Because your data is Zero-Knowledge encrypted, you will use your '
                  'Emergency Key (.txt) file upon login to sync and unlock your vault.',
                  style: TextStyle(
                    fontSize: 12.5,
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
        const SizedBox(height: 20),

        // Email Label & Autofill Helper
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Account Email',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _handleUploadKeyForEmail,
              icon: const Icon(Icons.file_upload_outlined, size: 15),
              label: const Text(
                'Autofill from Key File',
                style: TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                foregroundColor: LightColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
            fontSize: 13.5,
          ),
          decoration: InputDecoration(
            hintText: 'name@example.com',
            hintStyle: TextStyle(
              color: isDark ? DarkColors.textSecondary : Colors.grey.shade400,
              fontSize: 13,
            ),
            prefixIcon: const Icon(Icons.email_outlined, size: 18),
            filled: true,
            fillColor: isDark ? DarkColors.background : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 10),

        if (_autofillNotice != null) ...<Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline,
                size: 15,
                color: healthyGreen,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _autofillNotice!,
                  style: const TextStyle(fontSize: 12, color: healthyGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                    style: const TextStyle(color: unhealthyRed, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSending ? null : _handleSendResetEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: LightColors.primary,
              foregroundColor: white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: _isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: white,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 18),
            label: Text(
              _isSending
                  ? 'Sending reset email...'
                  : 'Send Password Reset Link',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(final bool isDark) {
    final String email = _emailController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: healthyGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: healthyGreen,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Password Reset Email Sent!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? DarkColors.background : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? DarkColors.border : Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Next Steps to Restore Access:',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Open the reset email sent to $email and follow the link to choose your new password.\n\n'
                '2. Return to Pecunia and sign in with your email and new password.\n\n'
                '3. On sign in, you will be prompted to provide your Emergency Key (.txt) file to unlock and re-encrypt your vault with your new password.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              showSnackbar(
                context,
                'Password reset email sent. Log in after updating your password.',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: LightColors.primary,
              foregroundColor: white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Back to Sign In',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
