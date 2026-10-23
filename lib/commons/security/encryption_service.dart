import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';

/// Cryptographic service providing Zero-Knowledge Envelope Encryption
/// using AES-256-GCM and PBKDF2 (HMAC-SHA256, 100,000 iterations).
class EncryptionService {
  EncryptionService({final AesGcm? aesGcm, final Pbkdf2? pbkdf2})
    : _aesGcm = aesGcm ?? AesGcm.with256bits(),
      _pbkdf2 =
          pbkdf2 ??
          Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 100000, bits: 256);

  final AesGcm _aesGcm;
  final Pbkdf2 _pbkdf2;

  static const String cipherPrefix = 'enc:v1:';

  /// Generates a random 256-bit symmetric Data Encryption Key (DEK).
  Future<SecretKey> generateDataEncryptionKey() async {
    return _aesGcm.newSecretKey();
  }

  /// Generates 32 bytes of cryptographically secure random salt.
  List<int> generateSalt([final int length = 32]) {
    final Random random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  /// Derives a 256-bit Key Encryption Key (KEK) from a password and salt.
  Future<SecretKey> deriveKeyFromPassword(
    final String password,
    final List<int> salt,
  ) async {
    return _pbkdf2.deriveKeyFromPassword(password: password, nonce: salt);
  }

  /// Derives a 256-bit Key Encryption Key (KEK) from a 12-word recovery phrase and salt.
  Future<SecretKey> deriveKeyFromRecoveryPhrase(
    final String recoveryPhrase,
    final List<int> salt,
  ) async {
    final String normalized = recoveryPhrase.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    return _pbkdf2.deriveKeyFromPassword(password: normalized, nonce: salt);
  }

  /// Encrypts plaintext string using AES-256-GCM.
  /// Output format: `enc:v1:<base64-packed-iv-mac-ciphertext>`
  Future<String> encryptString(
    final String plaintext,
    final SecretKey key,
  ) async {
    if (plaintext.isEmpty) return plaintext;

    final List<int> clearBytes = utf8.encode(plaintext);
    final SecretBox secretBox = await _aesGcm.encrypt(
      clearBytes,
      secretKey: key,
    );

    // Pack: 12-byte Nonce + 16-byte Mac + Ciphertext
    final BytesBuilder builder = BytesBuilder();
    builder.add(secretBox.nonce);
    builder.add(secretBox.mac.bytes);
    builder.add(secretBox.cipherText);

    return '$cipherPrefix${base64Url.encode(builder.toBytes())}';
  }

  /// Decrypts ciphertext back to plaintext.
  /// If the string does NOT start with `enc:v1:`, it is returned as-is (backward compatibility).
  Future<String> decryptString(final String input, final SecretKey key) async {
    if (!input.startsWith(cipherPrefix)) {
      return input;
    }

    try {
      final String payload = input.substring(cipherPrefix.length);
      final Uint8List packed = base64Url.decode(payload);

      if (packed.length < 28) {
        return input;
      }

      final List<int> nonce = packed.sublist(0, 12);
      final List<int> macBytes = packed.sublist(12, 28);
      final List<int> cipherText = packed.sublist(28);

      final SecretBox secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: Mac(macBytes),
      );

      final List<int> decryptedBytes = await _aesGcm.decrypt(
        secretBox,
        secretKey: key,
      );

      return utf8.decode(decryptedBytes);
    } catch (_) {
      // In case of corrupt or invalid key, return input safely without crashing
      return input;
    }
  }

  /// Encrypts a double amount into an encrypted string.
  Future<String> encryptAmount(final double amount, final SecretKey key) async {
    return encryptString(amount.toString(), key);
  }

  /// Decrypts a stored amount. Supports legacy float numbers as well as encrypted strings.
  Future<double> decryptAmount(
    final dynamic rawAmount,
    final SecretKey key,
  ) async {
    if (rawAmount is num) {
      return rawAmount.toDouble();
    }
    if (rawAmount is String) {
      if (!rawAmount.startsWith(cipherPrefix)) {
        return double.tryParse(rawAmount) ?? 0.0;
      }
      final String decrypted = await decryptString(rawAmount, key);
      return double.tryParse(decrypted) ?? 0.0;
    }
    return 0.0;
  }

  /// Creates the envelope vault payload to store in `user.profile.vault`.
  Future<Map<String, dynamic>> createVault({
    required final SecretKey dek,
    required final String password,
    required final String recoveryPhrase,
    required final List<int> salt,
  }) async {
    final List<int> rawDek = await dek.extractBytes();
    final String rawDekBase64 = base64Url.encode(rawDek);

    final SecretKey kekPassword = await deriveKeyFromPassword(password, salt);
    final SecretKey kekRecovery = await deriveKeyFromRecoveryPhrase(
      recoveryPhrase,
      salt,
    );

    final String encByPassword = await encryptString(rawDekBase64, kekPassword);
    final String encByRecovery = await encryptString(rawDekBase64, kekRecovery);
    // Encrypt the recovery phrase with the password KEK so the authenticated
    // user can retrieve their exact original recovery phrase in future sessions.
    final String encRecoveryPhrase = await encryptString(
      recoveryPhrase,
      kekPassword,
    );

    return <String, dynamic>{
      'encryptedKeyByPassword': encByPassword,
      'encryptedKeyByRecovery': encByRecovery,
      'encryptedRecoveryPhrase': encRecoveryPhrase,
      'salt': base64Url.encode(salt),
      'version': 1,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Unlocks the master Data Encryption Key using the user's login password.
  Future<SecretKey?> unlockVaultWithPassword(
    final Map<String, dynamic> vault,
    final String password,
  ) async {
    try {
      final String? saltString = vault['salt'] as String?;
      final String? encByPassword = vault['encryptedKeyByPassword'] as String?;

      if (saltString == null || encByPassword == null) return null;

      final List<int> salt = base64Url.decode(saltString);
      final SecretKey kekPassword = await deriveKeyFromPassword(password, salt);

      final String rawDekBase64 = await decryptString(
        encByPassword,
        kekPassword,
      );
      if (rawDekBase64.startsWith(cipherPrefix)) {
        return null; // Decryption failed
      }

      // Also restore the recovery phrase into SessionVault if available
      final String? encRecoveryPhrase =
          vault['encryptedRecoveryPhrase'] as String?;
      if (encRecoveryPhrase != null) {
        final String phrase = await decryptString(
          encRecoveryPhrase,
          kekPassword,
        );
        if (!phrase.startsWith(cipherPrefix)) {
          SessionVault.instance.setRecoveryPhrase(phrase);
        }
      }

      final List<int> rawDek = base64Url.decode(rawDekBase64);
      return SecretKey(rawDek);
    } catch (_) {
      return null;
    }
  }

  /// Unlocks the master Data Encryption Key using the 12-word recovery phrase.
  Future<SecretKey?> unlockVaultWithRecoveryPhrase(
    final Map<String, dynamic> vault,
    final String recoveryPhrase,
  ) async {
    try {
      final String? saltString = vault['salt'] as String?;
      final String? encByRecovery = vault['encryptedKeyByRecovery'] as String?;

      if (saltString == null || encByRecovery == null) return null;

      final List<int> salt = base64Url.decode(saltString);
      final SecretKey kekRecovery = await deriveKeyFromRecoveryPhrase(
        recoveryPhrase,
        salt,
      );

      final String rawDekBase64 = await decryptString(
        encByRecovery,
        kekRecovery,
      );
      if (rawDekBase64.startsWith(cipherPrefix)) {
        return null; // Decryption failed
      }

      final List<int> rawDek = base64Url.decode(rawDekBase64);
      return SecretKey(rawDek);
    } catch (_) {
      return null;
    }
  }
}
