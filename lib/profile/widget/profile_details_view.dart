import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsReceivable/repository/accounts_receivable_repository.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/accountsToPay/repository/accounts_to_pay_repository.dart';
import 'package:web_personal_finances/commons/export/csv_export_service.dart';
import 'package:web_personal_finances/commons/security/bip39_words.dart';
import 'package:web_personal_finances/commons/security/encryption_service.dart';
import 'package:web_personal_finances/commons/security/recovery_key_utils.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';
import 'package:web_personal_finances/expenses/repository/expenses_repository.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
import 'package:web_personal_finances/incomes/repository/incomes_repository.dart';
import 'package:web_personal_finances/profile/widget/profile_info_card.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/savings/model/saving_item.dart';
import 'package:web_personal_finances/savings/repository/savings_repository.dart';
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
            ? '${user.primaryCurrency} (${context.translate('dual_mode_enabled')})'
            : user.primaryCurrency;

        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: <Widget>[
            SizedBox(
              width: cardWidth,
              child: ProfileInfoCard(
                isDark: isDark,
                title: context.translate('full_name'),
                value: user.fullName.isNotEmpty
                    ? user.fullName
                    : context.translate('not_specified'),
                icon: Icons.person_outline,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: ProfileInfoCard(
                isDark: isDark,
                title: context.translate('profession_occupation'),
                value: user.profession.isNotEmpty
                    ? user.profession
                    : context.translate('not_specified'),
                icon: Icons.work_outline,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: ProfileInfoCard(
                isDark: isDark,
                title: context.translate('birth_date'),
                value: user.birthDate.isNotEmpty
                    ? user.birthDate
                    : context.translate('not_specified'),
                icon: Icons.cake_outlined,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: ProfileInfoCard(
                isDark: isDark,
                title: context.translate('primary_supported_currencies'),
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
                            context.translate('zk_encryption_vault'),
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
                                ? context.translate('vault_status_active')
                                : context.translate('vault_status_standard'),
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
                            context.translate('emergency_key_downloaded'),
                          );
                        } else if (context.mounted) {
                          showSnackbar(
                            context,
                            context.translate(
                              'unable_to_retrieve_recovery_key',
                            ),
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
                      label: Text(context.translate('download_backup_key')),
                    ),
                  ],
                ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: LightColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.file_download_outlined,
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
                                context.translate(
                                  'data_portability_csv_export',
                                ),
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
                                context.translate(
                                  'data_portability_description',
                                ),
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
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        OutlinedButton.icon(
                          onPressed: () async {
                            final List<IncomeItem> incomes =
                                await IncomeRepository()
                                    .getIncomes(user.uid)
                                    .first;
                            const CsvExportService().exportIncomes(incomes);
                            if (context.mounted) {
                              showSnackbar(
                                context,
                                context.translate('incomes_csv_exported'),
                              );
                            }
                          },
                          icon: const Icon(Icons.arrow_downward, size: 16),
                          label: Text(context.translate('export_incomes')),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final List<ExpenseItem> expenses =
                                await ExpenseRepository()
                                    .getExpenses(user.uid)
                                    .first;
                            const CsvExportService().exportExpenses(expenses);
                            if (context.mounted) {
                              showSnackbar(
                                context,
                                context.translate('expenses_csv_exported'),
                              );
                            }
                          },
                          icon: const Icon(Icons.arrow_upward, size: 16),
                          label: Text(context.translate('export_expenses')),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final List<AccountToPayItem> debts =
                                await AccountToPayRepository()
                                    .getAccountsToPay(user.uid)
                                    .first;
                            const CsvExportService().exportAccountsToPay(debts);
                            if (context.mounted) {
                              showSnackbar(
                                context,
                                context.translate(
                                  'accounts_to_pay_csv_exported',
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.credit_card, size: 16),
                          label: Text(context.translate('export_debts')),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final List<AccountReceivableItem> receivables =
                                await AccountReceivableRepository()
                                    .getAccountsReceivable(user.uid)
                                    .first;
                            const CsvExportService().exportAccountsReceivable(
                              receivables,
                            );
                            if (context.mounted) {
                              showSnackbar(
                                context,
                                context.translate(
                                  'accounts_receivable_csv_exported',
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.handshake_outlined, size: 16),
                          label: Text(context.translate('export_receivables')),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final List<SavingItem> savings =
                                await SavingsRepository()
                                    .getSavings(user.uid)
                                    .first;
                            const CsvExportService().exportSavings(savings);
                            if (context.mounted) {
                              showSnackbar(
                                context,
                                context.translate('savings_csv_exported'),
                              );
                            }
                          },
                          icon: const Icon(Icons.savings_outlined, size: 16),
                          label: Text(context.translate('export_savings')),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final List<IncomeItem> inList =
                                await IncomeRepository()
                                    .getIncomes(user.uid)
                                    .first;
                            final List<ExpenseItem> exList =
                                await ExpenseRepository()
                                    .getExpenses(user.uid)
                                    .first;
                            final List<AccountToPayItem> atpList =
                                await AccountToPayRepository()
                                    .getAccountsToPay(user.uid)
                                    .first;
                            final List<AccountReceivableItem> arList =
                                await AccountReceivableRepository()
                                    .getAccountsReceivable(user.uid)
                                    .first;
                            final List<SavingItem> svList =
                                await SavingsRepository()
                                    .getSavings(user.uid)
                                    .first;

                            const CsvExportService exp = CsvExportService();
                            exp.exportIncomes(inList);
                            exp.exportExpenses(exList);
                            exp.exportAccountsToPay(atpList);
                            exp.exportAccountsReceivable(arList);
                            exp.exportSavings(svList);

                            if (context.mounted) {
                              showSnackbar(
                                context,
                                context.translate('all_datasets_exported'),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LightColors.primary,
                            foregroundColor: white,
                          ),
                          icon: const Icon(
                            Icons.download_for_offline,
                            size: 16,
                          ),
                          label: Text(context.translate('export_all_datasets')),
                        ),
                      ],
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
