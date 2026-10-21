import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';

class AccountReceivableRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'accountsReceivable';

  Future<void> addAccountReceivable(final AccountReceivableItem item) async {
    await _firestore.collection(_collection).doc(item.id).set(item.toMap());
  }

  Future<void> updateAccountReceivable(final AccountReceivableItem item) async {
    await _firestore.collection(_collection).doc(item.id).update(item.toMap());
  }

  Future<void> deleteAccountReceivable(final String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Stream<List<AccountReceivableItem>> getAccountsReceivable(
    final String userId,
  ) {
    if (userId.isEmpty) {
      return Stream<List<AccountReceivableItem>>.value(
        <AccountReceivableItem>[],
      );
    }
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((final QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs
              .map(
                (final QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    AccountReceivableItem.fromMap(doc.data()),
              )
              .toList();
        });
  }
}
