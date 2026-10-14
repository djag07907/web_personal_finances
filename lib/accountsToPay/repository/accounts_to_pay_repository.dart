import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';

class AccountToPayRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'accountsToPay';

  Future<void> addAccountToPay(final AccountToPayItem item) async {
    await _firestore.collection(_collection).doc(item.id).set(item.toMap());
  }

  Future<void> updateAccountToPay(final AccountToPayItem item) async {
    await _firestore.collection(_collection).doc(item.id).update(item.toMap());
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
        .map((final QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs
              .map(
                (final QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    AccountToPayItem.fromMap(doc.data()),
              )
              .toList();
        });
  }
}
