import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({final FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveUser(final UserModel user) async {
    await _firestore
        .collection('profile')
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(final String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
        .collection('profile')
        .doc(uid)
        .get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Stream<UserModel?> streamUser(final String uid) {
    return _firestore.collection('profile').doc(uid).snapshots().map((
      final DocumentSnapshot<Map<String, dynamic>> doc,
    ) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }
}
