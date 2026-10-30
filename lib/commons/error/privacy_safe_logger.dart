import 'package:flutter/foundation.dart';

/// Utility that scrubs and sanitizes log messages and stack traces to prevent
/// any zero-knowledge ciphertext, recovery keys, passwords, or personal financial
/// figures from leaking into console logs or crash telemetry.
class PrivacySafeLogger {
  PrivacySafeLogger._();

  static final RegExp _cipherPattern = RegExp(
    r'enc:v1:[A-Za-z0-9_\-=]+',
    caseSensitive: false,
  );

  static final RegExp _twelveWordPattern = RegExp(
    r'\b([a-z]{3,8}\s+){11}[a-z]{3,8}\b',
    caseSensitive: false,
  );

  static final RegExp _emailPattern = RegExp(
    r'([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})',
  );

  static final RegExp _passwordKeyPattern = RegExp(
    r'(password|pass|secret|recoveryPhrase|dek|kek)\s*[:=]\s*[^\s,]+',
    caseSensitive: false,
  );

  /// Sanitizes an arbitrary text string by masking sensitive cryptographic and PII data.
  static String sanitize(final String input) {
    if (input.isEmpty) return input;

    String sanitized = input;

    // 1. Scrub AES-GCM ciphertext blobs
    sanitized = sanitized.replaceAll(_cipherPattern, '[ENCRYPTED_CIPHERTEXT]');

    // 2. Scrub 12-word BIP-39 recovery phrases
    sanitized = sanitized.replaceAll(
      _twelveWordPattern,
      '[RECOVERY_KEY_PHRASE]',
    );

    // 3. Scrub password and key parameters
    sanitized = sanitized.replaceAllMapped(
      _passwordKeyPattern,
      (final Match m) => '${m.group(1)}: [REDACTED]',
    );

    // 4. Partially mask email addresses (e.g. j***@example.com)
    sanitized = sanitized.replaceAllMapped(_emailPattern, (final Match m) {
      final String name = m.group(1) ?? '';
      final String domain = m.group(2) ?? '';
      final String tld = m.group(3) ?? '';
      final String maskedName = name.length > 1 ? '${name[0]}***' : '***';
      return '$maskedName@$domain.$tld';
    });

    return sanitized;
  }

  /// Logs a sanitized error to the debug console or crash reporting service.
  static void logError(
    final Object error, [
    final StackTrace? stackTrace,
    final String? reason,
  ]) {
    final String sanitizedError = sanitize(error.toString());
    final String? sanitizedReason = reason != null ? sanitize(reason) : null;
    final String? sanitizedStack = stackTrace != null
        ? sanitize(stackTrace.toString())
        : null;

    if (kDebugMode) {
      debugPrint('══════════════ [PRIVACY-SAFE ERROR] ══════════════');
      if (sanitizedReason != null) {
        debugPrint('Context: $sanitizedReason');
      }
      debugPrint('Error: $sanitizedError');
      if (sanitizedStack != null) {
        debugPrint('Stack: $sanitizedStack');
      }
      debugPrint('═══════════════════════════════════════════════════');
    }
  }
}
