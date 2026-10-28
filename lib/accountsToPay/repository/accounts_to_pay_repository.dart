import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_payment.dart';
import 'package:web_personal_finances/commons/security/encryption_service.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';

class AccountToPayRepository {
  AccountToPayRepository({
    final FirebaseFirestore? firestore,
    final EncryptionService? encryptionService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _encryptionService = encryptionService ?? EncryptionService();

  final FirebaseFirestore _firestore;
  final EncryptionService _encryptionService;
  static const String _collection = 'accountsToPay';

  Future<void> addAccountToPay(final AccountToPayItem item) async {
    final Map<String, dynamic> data = item.toMap();
    final SecretKey? key = SessionVault.instance.currentDek;

    if (key != null) {
      data['creditorName'] = await _encryptionService.encryptString(
        item.creditorName,
        key,
      );
      data['description'] = await _encryptionService.encryptString(
        item.description,
        key,
      );
      data['amount'] = await _encryptionService.encryptAmount(item.amount, key);
      if (item.monthlyQuota != null) {
        data['monthlyQuota'] = await _encryptionService.encryptAmount(
          item.monthlyQuota!,
          key,
        );
      }
      if (item.paymentMethod != null && item.paymentMethod!.isNotEmpty) {
        data['paymentMethod'] = await _encryptionService.encryptString(
          item.paymentMethod!,
          key,
        );
      }

      if (item.payments.isNotEmpty) {
        final List<Map<String, dynamic>> encryptedPayments =
            <Map<String, dynamic>>[];
        for (final AccountToPayPayment p in item.payments) {
          final Map<String, dynamic> pData = p.toMap();
          pData['amount'] = await _encryptionService.encryptAmount(
            p.amount,
            key,
          );
          if (p.paymentMethod != null && p.paymentMethod!.isNotEmpty) {
            pData['paymentMethod'] = await _encryptionService.encryptString(
              p.paymentMethod!,
              key,
            );
          }
          if (p.notes != null && p.notes!.isNotEmpty) {
            pData['notes'] = await _encryptionService.encryptString(
              p.notes!,
              key,
            );
          }
          encryptedPayments.add(pData);
        }
        data['payments'] = encryptedPayments;
      }
    }

    await _firestore.collection(_collection).doc(item.id).set(data);
  }

  Future<void> updateAccountToPay(final AccountToPayItem item) async {
    final Map<String, dynamic> data = item.toMap();
    final SecretKey? key = SessionVault.instance.currentDek;

    if (key != null) {
      data['creditorName'] = await _encryptionService.encryptString(
        item.creditorName,
        key,
      );
      data['description'] = await _encryptionService.encryptString(
        item.description,
        key,
      );
      data['amount'] = await _encryptionService.encryptAmount(item.amount, key);
      if (item.monthlyQuota != null) {
        data['monthlyQuota'] = await _encryptionService.encryptAmount(
          item.monthlyQuota!,
          key,
        );
      }
      if (item.paymentMethod != null && item.paymentMethod!.isNotEmpty) {
        data['paymentMethod'] = await _encryptionService.encryptString(
          item.paymentMethod!,
          key,
        );
      }

      if (item.payments.isNotEmpty) {
        final List<Map<String, dynamic>> encryptedPayments =
            <Map<String, dynamic>>[];
        for (final AccountToPayPayment p in item.payments) {
          final Map<String, dynamic> pData = p.toMap();
          pData['amount'] = await _encryptionService.encryptAmount(
            p.amount,
            key,
          );
          if (p.paymentMethod != null && p.paymentMethod!.isNotEmpty) {
            pData['paymentMethod'] = await _encryptionService.encryptString(
              p.paymentMethod!,
              key,
            );
          }
          if (p.notes != null && p.notes!.isNotEmpty) {
            pData['notes'] = await _encryptionService.encryptString(
              p.notes!,
              key,
            );
          }
          encryptedPayments.add(pData);
        }
        data['payments'] = encryptedPayments;
      }
    }

    await _firestore.collection(_collection).doc(item.id).update(data);
  }

  Future<void> deleteAccountToPay(final String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Stream<List<AccountToPayItem>> getAccountsToPay(final String userId) {
    if (userId.isEmpty) {
      return Stream<List<AccountToPayItem>>.value(<AccountToPayItem>[]);
    }
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((final QuerySnapshot<Map<String, dynamic>> snapshot) async {
          final SecretKey? key = SessionVault.instance.currentDek;
          final List<AccountToPayItem> items = <AccountToPayItem>[];

          for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.docs) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(
              doc.data(),
            );

            if (key != null) {
              if (data['creditorName'] is String) {
                data['creditorName'] = await _encryptionService.decryptString(
                  data['creditorName'] as String,
                  key,
                );
              }
              if (data['description'] is String) {
                data['description'] = await _encryptionService.decryptString(
                  data['description'] as String,
                  key,
                );
              }
              if (data.containsKey('amount')) {
                data['amount'] = await _encryptionService.decryptAmount(
                  data['amount'],
                  key,
                );
              }
              if (data.containsKey('monthlyQuota') &&
                  data['monthlyQuota'] != null) {
                data['monthlyQuota'] = await _encryptionService.decryptAmount(
                  data['monthlyQuota'],
                  key,
                );
              }
              if (data['paymentMethod'] is String) {
                data['paymentMethod'] = await _encryptionService.decryptString(
                  data['paymentMethod'] as String,
                  key,
                );
              }
              if (data['payments'] is List) {
                final List<dynamic> rawPayments =
                    data['payments'] as List<dynamic>;
                final List<Map<String, dynamic>> decryptedPayments =
                    <Map<String, dynamic>>[];
                for (final dynamic rawP in rawPayments) {
                  if (rawP is Map) {
                    final Map<String, dynamic> pData =
                        Map<String, dynamic>.from(rawP);
                    if (pData.containsKey('amount')) {
                      pData['amount'] = await _encryptionService.decryptAmount(
                        pData['amount'],
                        key,
                      );
                    }
                    if (pData['paymentMethod'] is String) {
                      pData['paymentMethod'] = await _encryptionService
                          .decryptString(pData['paymentMethod'] as String, key);
                    }
                    if (pData['notes'] is String) {
                      pData['notes'] = await _encryptionService.decryptString(
                        pData['notes'] as String,
                        key,
                      );
                    }
                    decryptedPayments.add(pData);
                  }
                }
                data['payments'] = decryptedPayments;
              }
            }
            items.add(AccountToPayItem.fromMap(data));
          }

          return items;
        });
  }
}
