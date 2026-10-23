import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:web_personal_finances/commons/security/bip39_words.dart';
import 'package:web_personal_finances/commons/security/encryption_service.dart';
import 'package:web_personal_finances/commons/security/recovery_key_utils.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/profile/widget/profile_info_card.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class ProfileDetailsView extends StatelessWidget {
  const ProfileDetailsView({
    required this.user,
    required this.isDark,
    super.key,
  });

  final UserModel user;
  final bool isDark;

  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final double cardWidth = constraints.maxWidth > 700
            ? (constraints.maxWidth - 20) / 2
            : constraints.maxWidth;

        final String currencyDisplay = user.enableDualCurrency
            ? '${user.primaryCurrency} (Dual Mode HNL & USD Enabled)'
            : user.primaryCurrency;

        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: <Widget>[
            SizedBox(
              width: cardWidth,
              child: ProfileInfoCard(
                isDark: isDark,
                title: 'Full Name',
                value: user.fullName.isNotEmpty
                    ? user.fullName
                    : 'Not specified',
                icon: Icons.person_outline,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: ProfileInfoCard(
                isDark: isDark,
                title: 'Profession / Occupation',
                value: user.profession.isNotEmpty
                    ? user.profession
                    : 'Not specified',
                icon: Icons.work_outline,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: ProfileInfoCard(
                isDark: isDark,
                title: 'Birth Date',
                value: user.birthDate.isNotEmpty
                    ? user.birthDate
                    : 'Not specified',
                icon: Icons.cake_outlined,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: ProfileInfoCard(
                isDark: isDark,
                title: 'Primary & Supported Currencies',
                value: currencyDisplay,
                icon: Icons.monetization_on_outlined,
              ),
            ),
            SizedBox(
              width: constraints.maxWidth,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? DarkColors.surface : white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? DarkColors.border : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: LightColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: LightColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Zero-Knowledge Encryption Vault',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? DarkColors.textPrimary
                                  : LightColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.vault != null
                                ? 'Status: Active (AES-256-GCM). Your sensitive financial records are protected.'
                                : 'Status: Standard cloud security active.',
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
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        String? phrase = SessionVault.instance.recoveryPhrase;
                        if (phrase == null) {
                          final SecretKey? dek =
                              SessionVault.instance.currentDek;
                          if (dek != null && user.vault != null) {
                            phrase = generateRecoveryPhrase();
                            final EncryptionService encryptionService =
                                EncryptionService();
                            final List<int> salt = encryptionService
                                .generateSalt();
                            final SecretKey kekRecovery =
                                await encryptionService
                                    .deriveKeyFromRecoveryPhrase(phrase, salt);
                            final List<int> rawDek = await dek.extractBytes();
                            final String rawDekBase64 = base64Url.encode(
                              rawDek,
                            );
                            final String encByRecovery = await encryptionService
                                .encryptString(rawDekBase64, kekRecovery);

                            final Map<String, dynamic> updatedVault =
                                Map<String, dynamic>.from(user.vault!);
                            updatedVault['encryptedKeyByRecovery'] =
                                encByRecovery;
                            await UserRepository().saveUser(
                              user.copyWith(vault: updatedVault),
                            );
                            SessionVault.instance.setRecoveryPhrase(phrase);
                          }
                        }

                        if (phrase != null && context.mounted) {
                          RecoveryKeyUtils.downloadEmergencyKey(
                            email: user.email,
                            uid: user.uid,
                            recoveryPhrase: phrase,
                          );
                          showSnackbar(
                            context,
                            'Emergency key backup file downloaded (matches your vault).',
                          );
                        } else if (context.mounted) {
                          showSnackbar(
                            context,
                            'Unable to retrieve recovery key. Please re-authenticate.',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LightColors.primary,
                        foregroundColor: white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download Backup Key'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
