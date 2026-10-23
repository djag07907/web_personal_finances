import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:web_personal_finances/commons/security/encryption_service.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';

class IncomeRepository {
  IncomeRepository({
    final FirebaseFirestore? firestore,
    final EncryptionService? encryptionService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _encryptionService = encryptionService ?? EncryptionService();

  final FirebaseFirestore _firestore;
  final EncryptionService _encryptionService;

  Future<void> addIncome(final IncomeItem incomeItem) async {
    final Map<String, dynamic> data = incomeItem.toMap();
    final SecretKey? key = SessionVault.instance.currentDek;

    if (key != null) {
      data['name'] = await _encryptionService.encryptString(
        incomeItem.name,
        key,
      );
      data['comment'] = await _encryptionService.encryptString(
        incomeItem.comment,
        key,
      );
      data['amount'] = await _encryptionService.encryptAmount(
        incomeItem.amount,
        key,
      );
    }

    await _firestore.collection('incomes').doc(incomeItem.id).set(data);
  }

  Future<void> updateIncome(final IncomeItem incomeItem) async {
    final Map<String, dynamic> data = incomeItem.toMap();
    final SecretKey? key = SessionVault.instance.currentDek;

    if (key != null) {
      data['name'] = await _encryptionService.encryptString(
        incomeItem.name,
        key,
      );
      data['comment'] = await _encryptionService.encryptString(
        incomeItem.comment,
        key,
      );
      data['amount'] = await _encryptionService.encryptAmount(
        incomeItem.amount,
        key,
      );
    }

    await _firestore.collection('incomes').doc(incomeItem.id).update(data);
  }

  Future<void> deleteIncome(final String id) async {
    await _firestore.collection('incomes').doc(id).delete();
  }

  Stream<List<IncomeItem>> getIncomes(final String userId) {
    if (userId.isEmpty) {
      return Stream<List<IncomeItem>>.value(<IncomeItem>[]);
    }
    return _firestore
        .collection('incomes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((final QuerySnapshot<Map<String, dynamic>> snapshot) async {
          final SecretKey? key = SessionVault.instance.currentDek;
          final List<IncomeItem> items = <IncomeItem>[];

          for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.docs) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(
              doc.data(),
            );

            if (key != null) {
              if (data['name'] is String) {
                data['name'] = await _encryptionService.decryptString(
                  data['name'] as String,
                  key,
                );
              }
              if (data['comment'] is String) {
                data['comment'] = await _encryptionService.decryptString(
                  data['comment'] as String,
                  key,
                );
              }
              if (data.containsKey('amount')) {
                data['amount'] = await _encryptionService.decryptAmount(
                  data['amount'],
                  key,
                );
              }
            }
            items.add(IncomeItem.fromMap(data));
          }

          return items;
        });
  }
}
