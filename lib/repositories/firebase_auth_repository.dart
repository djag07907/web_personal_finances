import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  AuthRepository({final FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailAndPassword({
    required final String email,
    required final String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required final String email,
    required final String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    SessionVault.instance.clear();
    return await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail({required final String email}) async {
    return await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Re-authenticates the current user with [password]. Throws a
  /// [FirebaseAuthException] if the password is not the current account password.
  Future<void> verifyPassword({required final String password}) async {
    final User? user = _firebaseAuth.currentUser;
    final String? email = user?.email;
    if (user == null || email == null) {
      throw FirebaseAuthException(code: 'no-current-user');
    }
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
  }

  Stream<User?> get userChanges => _firebaseAuth.userChanges();
}
