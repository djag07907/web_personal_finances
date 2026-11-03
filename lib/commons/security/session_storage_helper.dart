import 'package:web_personal_finances/commons/security/session_storage_stub.dart'
    if (dart.library.html) 'package:web_personal_finances/commons/security/session_storage_web.dart'
    as platform;

/// Saves the active Data Encryption Key into browser sessionStorage for the current tab.
void saveSessionDek({
  required final String uid,
  required final String rawDekBase64,
}) {
  platform.saveSessionDek(uid: uid, rawDekBase64: rawDekBase64);
}

/// Retrieves the active Data Encryption Key from browser sessionStorage for the current tab.
String? getSessionDek({required final String uid}) {
  return platform.getSessionDek(uid: uid);
}

/// Saves the active 12-word recovery phrase into browser sessionStorage for the current tab.
void saveSessionPhrase({
  required final String uid,
  required final String phrase,
}) {
  platform.saveSessionPhrase(uid: uid, phrase: phrase);
}

/// Retrieves the active 12-word recovery phrase from browser sessionStorage for the current tab.
String? getSessionPhrase({required final String uid}) {
  return platform.getSessionPhrase(uid: uid);
}

/// Clears all stored session keys from browser sessionStorage.
void clearSessionStorage() {
  platform.clearSessionStorage();
}
