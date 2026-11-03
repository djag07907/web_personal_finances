import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:web_personal_finances/commons/security/session_storage_helper.dart';

/// In-memory vault holding the decrypted Data Encryption Key (DEK)
/// for the authenticated user's current session.
///
/// Keys are stored in transient browser memory (and tab-scoped sessionStorage)
/// to survive in-tab reloads, and are wiped immediately on logout or tab close.
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

  /// Sets the active Data Encryption Key in memory and syncs to sessionStorage.
  Future<void> setDek(final SecretKey dek, {final String? uid}) async {
    _currentDek = dek;
    if (uid != null && uid.isNotEmpty) {
      try {
        final List<int> bytes = await dek.extractBytes();
        saveSessionDek(uid: uid, rawDekBase64: base64Url.encode(bytes));
      } catch (_) {}
    }
    notifyListeners();
  }

  /// Attempts to restore the active DEK from browser sessionStorage for [uid].
  bool tryRestoreFromSession(final String uid) {
    if (_currentDek != null) return true;
    if (uid.isEmpty) return false;
    final String? stored = getSessionDek(uid: uid);
    if (stored != null && stored.isNotEmpty) {
      try {
        final List<int> bytes = base64Url.decode(stored);
        _currentDek = SecretKey(bytes);
        final String? phrase = getSessionPhrase(uid: uid);
        if (phrase != null && phrase.isNotEmpty) {
          _recoveryPhrase = phrase;
        }
        notifyListeners();
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  /// Sets the temporary auth password in memory.
  void setPendingAuthPassword(final String password) {
    _pendingAuthPassword = password;
  }

  /// Removes the temporary auth password once it is no longer needed.
  void clearPendingAuthPassword() {
    _pendingAuthPassword = null;
  }

  /// Sets the active recovery phrase in memory and syncs to sessionStorage.
  void setRecoveryPhrase(final String phrase, {final String? uid}) {
    _recoveryPhrase = phrase;
    if (uid != null && uid.isNotEmpty) {
      saveSessionPhrase(uid: uid, phrase: phrase);
    }
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

  /// Wipes all sensitive keys and passwords from memory and sessionStorage. Called on user sign out.
  void clear() {
    _currentDek = null;
    _pendingAuthPassword = null;
    _recoveryPhrase = null;
    _isUnlockInProgress = false;
    clearSessionStorage();
    notifyListeners();
  }
}
