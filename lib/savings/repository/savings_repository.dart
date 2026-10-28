import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:web_personal_finances/commons/security/encryption_service.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';
import 'package:web_personal_finances/savings/model/saving_item.dart';
import 'package:web_personal_finances/savings/model/saving_registry_item.dart';

class SavingsRepository {
  SavingsRepository({
    final FirebaseFirestore? firestore,
    final EncryptionService? encryptionService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _encryptionService = encryptionService ?? EncryptionService();

  final FirebaseFirestore _firestore;
  final EncryptionService _encryptionService;
  static const String _collection = 'savings';

  Future<void> addSaving(final SavingItem item) async {
    final Map<String, dynamic> data = item.toMap();
    final SecretKey? key = SessionVault.instance.currentDek;

    if (key != null) {
      data['name'] = await _encryptionService.encryptString(item.name, key);
      data['comment'] = await _encryptionService.encryptString(
        item.comment,
        key,
      );
      data['amount'] = await _encryptionService.encryptAmount(item.amount, key);
      data['goalAmount'] = await _encryptionService.encryptAmount(
        item.goalAmount,
        key,
      );

      if (item.registries.isNotEmpty) {
        final List<Map<String, dynamic>> encryptedRegistries =
            <Map<String, dynamic>>[];
        for (final SavingRegistryItem r in item.registries) {
          final Map<String, dynamic> rData = r.toMap();
          rData['amount'] = await _encryptionService.encryptAmount(
            r.amount,
            key,
          );
          if (r.comment != null && r.comment!.isNotEmpty) {
            rData['comment'] = await _encryptionService.encryptString(
              r.comment!,
              key,
            );
          }
          encryptedRegistries.add(rData);
        }
        data['registries'] = encryptedRegistries;
      }
    }

    await _firestore.collection(_collection).doc(item.id).set(data);
  }

  Future<void> updateSaving(final SavingItem item) async {
    final Map<String, dynamic> data = item.toMap();
    final SecretKey? key = SessionVault.instance.currentDek;

    if (key != null) {
      data['name'] = await _encryptionService.encryptString(item.name, key);
      data['comment'] = await _encryptionService.encryptString(
        item.comment,
        key,
      );
      data['amount'] = await _encryptionService.encryptAmount(item.amount, key);
      data['goalAmount'] = await _encryptionService.encryptAmount(
        item.goalAmount,
        key,
      );

      if (item.registries.isNotEmpty) {
        final List<Map<String, dynamic>> encryptedRegistries =
            <Map<String, dynamic>>[];
        for (final SavingRegistryItem r in item.registries) {
          final Map<String, dynamic> rData = r.toMap();
          rData['amount'] = await _encryptionService.encryptAmount(
            r.amount,
            key,
          );
          if (r.comment != null && r.comment!.isNotEmpty) {
            rData['comment'] = await _encryptionService.encryptString(
              r.comment!,
              key,
            );
          }
          encryptedRegistries.add(rData);
        }
        data['registries'] = encryptedRegistries;
      }
    }

    await _firestore.collection(_collection).doc(item.id).update(data);
  }

  Future<void> deleteSaving(final String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<void> recordTransaction({
    required final String savingId,
    required final SavingRegistryItem transaction,
  }) async {
    final DocumentReference<Map<String, dynamic>> docRef = _firestore
        .collection(_collection)
        .doc(savingId);

    final Map<String, dynamic> tData = transaction.toMap();
    final SecretKey? key = SessionVault.instance.currentDek;
    if (key != null) {
      tData['amount'] = await _encryptionService.encryptAmount(
        transaction.amount,
        key,
      );
      if (transaction.comment != null && transaction.comment!.isNotEmpty) {
        tData['comment'] = await _encryptionService.encryptString(
          transaction.comment!,
          key,
        );
      }
    }

    await docRef.update(<String, dynamic>{
      'registries': FieldValue.arrayUnion(<dynamic>[tData]),
    });
  }

  Stream<List<SavingItem>> getSavings(final String userId) {
    if (userId.isEmpty) {
      return Stream<List<SavingItem>>.value(<SavingItem>[]);
    }
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((final QuerySnapshot<Map<String, dynamic>> snapshot) async {
          final SecretKey? key = SessionVault.instance.currentDek;
          final List<SavingItem> items = <SavingItem>[];

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
              if (data.containsKey('goalAmount')) {
                data['goalAmount'] = await _encryptionService.decryptAmount(
                  data['goalAmount'],
                  key,
                );
              }
              if (data['registries'] is List) {
                final List<dynamic> rawRegistries =
                    data['registries'] as List<dynamic>;
                final List<Map<String, dynamic>> decryptedRegistries =
                    <Map<String, dynamic>>[];
                for (final dynamic rawR in rawRegistries) {
                  if (rawR is Map) {
                    final Map<String, dynamic> rData =
                        Map<String, dynamic>.from(rawR);
                    if (rData.containsKey('amount')) {
                      rData['amount'] = await _encryptionService.decryptAmount(
                        rData['amount'],
                        key,
                      );
                    }
                    if (rData['comment'] is String) {
                      rData['comment'] = await _encryptionService.decryptString(
                        rData['comment'] as String,
                        key,
                      );
                    }
                    decryptedRegistries.add(rData);
                  }
                }
                data['registries'] = decryptedRegistries;
              }
            }
            items.add(SavingItem.fromMap(data));
          }

          return items;
        });
  }
}
