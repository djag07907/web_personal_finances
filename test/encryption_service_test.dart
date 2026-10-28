import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_personal_finances/commons/security/bip39_words.dart';
import 'package:web_personal_finances/commons/security/encryption_service.dart';
import 'package:web_personal_finances/commons/security/recovery_key_utils.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';

void main() {
  group('EncryptionService Tests', () {
    late EncryptionService service;

    setUp(() {
      service = EncryptionService();
    });

    test('generates valid 256-bit DEK', () async {
      final SecretKey dek = await service.generateDataEncryptionKey();
      final List<int> bytes = await dek.extractBytes();
      expect(bytes.length, 32);
    });

    test('encrypts and decrypts strings correctly with AES-GCM', () async {
      final SecretKey dek = await service.generateDataEncryptionKey();
      const String original = 'Software Engineering Salary';

      final String ciphertext = await service.encryptString(original, dek);
      expect(ciphertext.startsWith(EncryptionService.cipherPrefix), isTrue);
      expect(ciphertext, isNot(equals(original)));

      final String decrypted = await service.decryptString(ciphertext, dek);
      expect(decrypted, equals(original));
    });

    test('encrypts and decrypts amounts correctly', () async {
      final SecretKey dek = await service.generateDataEncryptionKey();
      const double originalAmount = 4500.75;

      final String encrypted = await service.encryptAmount(originalAmount, dek);
      expect(encrypted.startsWith(EncryptionService.cipherPrefix), isTrue);

      final double decrypted = await service.decryptAmount(encrypted, dek);
      expect(decrypted, equals(originalAmount));
    });

    test('encrypts and decrypts expense payload fields (name, comment, amount, paymentMethod)', () async {
      final SecretKey dek = await service.generateDataEncryptionKey();
      const String expenseName = 'Supermarket Groceries';
      const String expenseComment = 'Weekly shopping at Walmart';
      const double expenseAmount = 142.85;
      const String paymentMethod = 'BAC Visa **** 1234';

      final String encName = await service.encryptString(expenseName, dek);
      final String encComment = await service.encryptString(expenseComment, dek);
      final String encAmount = await service.encryptAmount(expenseAmount, dek);
      final String encPaymentMethod = await service.encryptString(paymentMethod, dek);

      expect(encName.startsWith(EncryptionService.cipherPrefix), isTrue);
      expect(encComment.startsWith(EncryptionService.cipherPrefix), isTrue);
      expect(encAmount.startsWith(EncryptionService.cipherPrefix), isTrue);
      expect(encPaymentMethod.startsWith(EncryptionService.cipherPrefix), isTrue);

      expect(await service.decryptString(encName, dek), equals(expenseName));
      expect(await service.decryptString(encComment, dek), equals(expenseComment));
      expect(await service.decryptAmount(encAmount, dek), equals(expenseAmount));
      expect(await service.decryptString(encPaymentMethod, dek), equals(paymentMethod));
    });

    test(
      'backward compatibility: legacy unencrypted strings and numbers pass through',
      () async {
        final SecretKey dek = await service.generateDataEncryptionKey();

        // Legacy plaintext string
        const String legacyText = 'Legacy Consulting Income';
        final String decryptedText = await service.decryptString(
          legacyText,
          dek,
        );
        expect(decryptedText, equals(legacyText));

        // Legacy float number
        const double legacyNumber = 2500.50;
        final double decryptedNumber = await service.decryptAmount(
          legacyNumber,
          dek,
        );
        expect(decryptedNumber, equals(legacyNumber));
      },
    );

    test(
      'vault creation and unlocking with password & recovery phrase',
      () async {
        final SecretKey dek = await service.generateDataEncryptionKey();
        final List<int> originalDekBytes = await dek.extractBytes();
        final List<int> salt = service.generateSalt();
        const String password = 'MySuperSecretPassword123!';
        final String recoveryPhrase = generateRecoveryPhrase();

        final Map<String, dynamic> vault = await service.createVault(
          dek: dek,
          password: password,
          recoveryPhrase: recoveryPhrase,
          salt: salt,
        );

        expect(vault['encryptedKeyByPassword'], isNotNull);
        expect(vault['encryptedKeyByRecovery'], isNotNull);
        expect(vault['salt'], isNotNull);

        // 1. Unlock with password
        final SecretKey? unlockedByPassword = await service
            .unlockVaultWithPassword(vault, password);
        expect(unlockedByPassword, isNotNull);
        final List<int> passwordDekBytes = await unlockedByPassword!
            .extractBytes();
        expect(passwordDekBytes, equals(originalDekBytes));
        expect(SessionVault.instance.recoveryPhrase, equals(recoveryPhrase));

        // 2. Unlock with recovery phrase
        final SecretKey? unlockedByPhrase = await service
            .unlockVaultWithRecoveryPhrase(vault, recoveryPhrase);
        expect(unlockedByPhrase, isNotNull);
        final List<int> phraseDekBytes = await unlockedByPhrase!.extractBytes();
        expect(phraseDekBytes, equals(originalDekBytes));

        // 3. Failed unlock with wrong password
        final SecretKey? failedPassword = await service.unlockVaultWithPassword(
          vault,
          'WrongPassword!',
        );
        expect(failedPassword, isNull);

        // 4. Failed unlock with wrong recovery phrase
        final SecretKey?
        failedPhrase = await service.unlockVaultWithRecoveryPhrase(
          vault,
          'abandon ability able about above absent absorb abstract absurd abuse access accident',
        );
        expect(failedPhrase, isNull);
      },
    );
  });

  group('RecoveryKeyUtils Tests', () {
    test('formats and parses emergency key file', () {
      const String email = 'daniel@example.com';
      const String uid = 'test_uid_123';
      final String recoveryPhrase = generateRecoveryPhrase();

      final String fileContent = RecoveryKeyUtils.formatEmergencyKeyFile(
        email: email,
        uid: uid,
        recoveryPhrase: recoveryPhrase,
      );

      expect(
        fileContent.contains('PECUNIA PERSONAL FINANCES - EMERGENCY KEY'),
        isTrue,
      );
      expect(fileContent.contains(email), isTrue);
      expect(fileContent.contains(uid), isTrue);
      expect(fileContent.contains(recoveryPhrase), isTrue);

      final String? extracted = RecoveryKeyUtils.extractRecoveryPhrase(
        fileContent,
      );
      expect(extracted, equals(recoveryPhrase));

      final String? extractedEmail = RecoveryKeyUtils.extractEmail(fileContent);
      expect(extractedEmail, equals(email));
    });

    test('extracts direct 12-word string input', () {
      final String recoveryPhrase = generateRecoveryPhrase();
      final String? extracted = RecoveryKeyUtils.extractRecoveryPhrase(
        recoveryPhrase,
      );
      expect(extracted, equals(recoveryPhrase));
    });
  });

  group('SessionVault Tests', () {
    test('stores and clears keys and passwords', () async {
      final SessionVault vault = SessionVault.instance;
      vault.clear();
      expect(vault.hasActiveKey, isFalse);
      expect(vault.currentDek, isNull);
      expect(vault.recoveryPhrase, isNull);

      final SecretKey dek = await EncryptionService()
          .generateDataEncryptionKey();
      vault.setDek(dek);
      expect(vault.hasActiveKey, isTrue);
      expect(vault.currentDek, equals(dek));

      vault.setPendingAuthPassword('temporaryPass');
      expect(vault.pendingAuthPassword, equals('temporaryPass'));

      vault.setRecoveryPhrase(
        'abandon ability able about above absent absorb abstract absurd abuse access accident',
      );
      expect(vault.recoveryPhrase, isNotNull);

      vault.clear();
      expect(vault.hasActiveKey, isFalse);
      expect(vault.currentDek, isNull);
      expect(vault.pendingAuthPassword, isNull);
      expect(vault.recoveryPhrase, isNull);
    });
  });
}
