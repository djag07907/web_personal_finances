import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';

class IncomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> addIncome(final IncomeItem incomeItem) async {
    await _firestore
        .collection('incomes')
        .doc(incomeItem.id)
        .set(incomeItem.toMap());
  }

  Future<void> updateIncome(final IncomeItem incomeItem) async {
    await _firestore
        .collection('incomes')
        .doc(incomeItem.id)
        .update(incomeItem.toMap());
  }

  Future<void> deleteIncome(final String id) async {
    await _firestore.collection('incomes').doc(id).delete();
  }

  Stream<List<IncomeItem>> getIncomes() {
    return _firestore
        .collection('incomes')
        .snapshots()
        .map((final QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs
          .map(
            (final QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                IncomeItem.fromMap(doc.data()),
          )
          .toList();
    });
  }
}
