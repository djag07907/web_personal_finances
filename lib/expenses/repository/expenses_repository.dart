import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addExpense(final ExpenseItem expenseItem) async {
    await _firestore
        .collection('expenses')
        .doc(expenseItem.id)
        .set(expenseItem.toMap());
  }

  Future<void> updateExpense(final ExpenseItem expenseItem) async {
    await _firestore
        .collection('expenses')
        .doc(expenseItem.id)
        .update(expenseItem.toMap());
  }

  Future<void> deleteExpense(final String id) async {
    await _firestore.collection('expenses').doc(id).delete();
  }

  Stream<List<ExpenseItem>> getExpenses(final String userId) {
    if (userId.isEmpty) {
      return Stream<List<ExpenseItem>>.value(<ExpenseItem>[]);
    }
    return _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((final QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs
              .map(
                (final QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    ExpenseItem.fromMap(doc.data()),
              )
              .toList();
        });
  }
}
