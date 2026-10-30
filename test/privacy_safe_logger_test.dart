import 'package:flutter_test/flutter_test.dart';
import 'package:web_personal_finances/commons/error/privacy_safe_logger.dart';

void main() {
  group('PrivacySafeLogger Tests', () {
    test('sanitizes ciphertext strings starting with enc:v1:', () {
      const String input =
          'Failed parsing doc: enc:v1:YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoxMjM0NTY= at line 4';
      final String result = PrivacySafeLogger.sanitize(input);

      expect(result.contains('enc:v1:'), isFalse);
      expect(result.contains('[ENCRYPTED_CIPHERTEXT]'), isTrue);
    });

    test('sanitizes 12-word recovery phrases', () {
      const String phrase =
          'ocean timber flame silver castle winter apple cloud river sunset gold anchor';
      final String input =
          'User tried unlocking with phrase: $phrase in session';
      final String result = PrivacySafeLogger.sanitize(input);

      expect(result.contains('ocean timber flame'), isFalse);
      expect(result.contains('[RECOVERY_KEY_PHRASE]'), isTrue);
    });

    test('sanitizes password and key parameters', () {
      const String input =
          'Auth failed for password: mySecretPassword123! with dek: 38294829';
      final String result = PrivacySafeLogger.sanitize(input);

      expect(result.contains('mySecretPassword123!'), isFalse);
      expect(result.contains('38294829'), isFalse);
      expect(result.contains('password: [REDACTED]'), isTrue);
      expect(result.contains('dek: [REDACTED]'), isTrue);
    });

    test('partially masks email addresses', () {
      const String input =
          'User account daniel@example.com experienced sync failure';
      final String result = PrivacySafeLogger.sanitize(input);

      expect(result.contains('daniel@example.com'), isFalse);
      expect(result.contains('d***@example.com'), isTrue);
    });
  });
}
