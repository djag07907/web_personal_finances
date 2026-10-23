import 'package:web_personal_finances/commons/security/file_download_helper.dart';

class RecoveryKeyUtils {
  /// Generates the human-readable text content for the emergency key backup file.
  static String formatEmergencyKeyFile({
    required final String email,
    required final String uid,
    required final String recoveryPhrase,
  }) {
    final String dateString = DateTime.now().toIso8601String().split('T').first;

    return '''
=====================================================
         PECUNIA PERSONAL FINANCES - EMERGENCY KEY
=====================================================
Account Email : $email
Account UID   : $uid
Created Date  : $dateString

RECOVERY KEY:
$recoveryPhrase

IMPORTANT INSTRUCTIONS:
1. Store this emergency key in a safe, secure location (e.g. password manager, USB drive).
2. If you ever forget your password, you will need this file to recover and decrypt your financial records.
3. Pecunia employees and cloud administrators cannot decrypt or recover your data without this key.
=====================================================
''';
  }

  /// Triggers a download of the emergency key file in the user's browser.
  static void downloadEmergencyKey({
    required final String email,
    required final String uid,
    required final String recoveryPhrase,
  }) {
    final String sanitizedEmail = email.replaceAll(
      RegExp(r'[^a-zA-Z0-9_]'),
      '_',
    );
    final String filename = 'pecunia_emergency_key_$sanitizedEmail.txt';
    final String content = formatEmergencyKeyFile(
      email: email,
      uid: uid,
      recoveryPhrase: recoveryPhrase,
    );

    downloadTextFile(filename: filename, content: content);
  }

  /// Parses and extracts the 12-word recovery phrase from an uploaded key file's content or raw string.
  static String? extractRecoveryPhrase(final String fileContent) {
    if (fileContent.isEmpty) return null;

    // Check if the file contains the "RECOVERY KEY:" header
    if (fileContent.contains('RECOVERY KEY:')) {
      final List<String> lines = fileContent.split('\n');
      final int keyHeaderIndex = lines.indexWhere(
        (final String line) => line.trim().startsWith('RECOVERY KEY:'),
      );
      if (keyHeaderIndex != -1 && keyHeaderIndex + 1 < lines.length) {
        for (int i = keyHeaderIndex + 1; i < lines.length; i++) {
          final String candidate = lines[i].trim();
          if (candidate.isNotEmpty && !candidate.startsWith('=')) {
            final List<String> words = candidate.split(RegExp(r'\s+'));
            if (words.length >= 12) {
              return words.sublist(0, 12).join(' ');
            }
          }
        }
      }
    }

    // Direct phrase input fallback (e.g. user pasted the 12 words directly)
    final List<String> words = fileContent.trim().split(RegExp(r'\s+'));
    if (words.length == 12) {
      return words.join(' ');
    }

    return null;
  }

  /// Extracts the account email from the formatted emergency key file if present.
  static String? extractEmail(final String fileContent) {
    if (fileContent.isEmpty) return null;
    final RegExp emailRegExp = RegExp(
      r'Account Email\s*:\s*([^\s\r\n]+)',
      caseSensitive: false,
    );
    final Match? match = emailRegExp.firstMatch(fileContent);
    return match?.group(1)?.trim();
  }
}
