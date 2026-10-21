import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_personal_finances/savings/model/saving_item.dart';
import 'package:web_personal_finances/savings/model/saving_registry_item.dart';

class SavingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'savings';

  Future<void> addSaving(final SavingItem item) async {
    await _firestore.collection(_collection).doc(item.id).set(item.toMap());
  }

  Future<void> updateSaving(final SavingItem item) async {
    await _firestore.collection(_collection).doc(item.id).update(item.toMap());
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
    await docRef.update(<String, dynamic>{
      'registries': FieldValue.arrayUnion(<dynamic>[transaction.toMap()]),
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
        .map((final QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs
              .map(
                (final QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    SavingItem.fromMap(doc.data()),
              )
              .toList();
        });
  }
}
