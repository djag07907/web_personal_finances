import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

/// In-memory vault holding the decrypted Data Encryption Key (DEK)
/// for the authenticated user's current session.
///
/// Keys are never persisted in plaintext and are immediately wiped on logout.
class SessionVault extends ChangeNotifier {
  SessionVault._();

  static final SessionVault instance = SessionVault._();

  SecretKey? _currentDek;
  String? _pendingAuthPassword;
  String? _recoveryPhrase;
  bool _isUnlockInProgress = false;

  /// `true` while the login flow is still trying to unlock the vault with the
  /// login password. Prevents the router from gating the app prematurely.
  bool get isUnlockInProgress => _isUnlockInProgress;

  /// Returns `true` if the session has an active, decrypted Data Encryption Key.
  bool get hasActiveKey => _currentDek != null;

  /// The active 256-bit AES Data Encryption Key for the current session.
  SecretKey? get currentDek => _currentDek;

  /// Temporary login/signup password used during onboarding vault initialization.
  String? get pendingAuthPassword => _pendingAuthPassword;

  /// The user's active 12-word recovery phrase for the session, if available.
  String? get recoveryPhrase => _recoveryPhrase;

  /// Sets the active Data Encryption Key in memory.
  void setDek(final SecretKey dek) {
    _currentDek = dek;
  }

  /// Sets the temporary auth password in memory.
  void setPendingAuthPassword(final String password) {
    _pendingAuthPassword = password;
  }

  /// Removes the temporary auth password once it is no longer needed.
  void clearPendingAuthPassword() {
    _pendingAuthPassword = null;
  }

  /// Sets the active recovery phrase in memory.
  void setRecoveryPhrase(final String phrase) {
    _recoveryPhrase = phrase;
  }

  /// Marks the start of the login-time vault unlock attempt.
  void beginUnlock() {
    _isUnlockInProgress = true;
  }

  /// Marks the end of the login-time vault unlock attempt and notifies
  /// listeners (e.g. the router) so the lock state is re-evaluated.
  void endUnlock() {
    _isUnlockInProgress = false;
    notifyListeners();
  }

  /// Wipes all sensitive keys and passwords from memory. Called on user sign out.
  void clear() {
    _currentDek = null;
    _pendingAuthPassword = null;
    _recoveryPhrase = null;
    _isUnlockInProgress = false;
    notifyListeners();
  }
}
