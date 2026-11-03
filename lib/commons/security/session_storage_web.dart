import 'dart:html' as html;

const String _dekPrefix = 'pecunia_session_dek_';
const String _phrasePrefix = 'pecunia_session_phrase_';

/// Saves the active DEK in browser sessionStorage for the current tab.
void saveSessionDek({
  required final String uid,
  required final String rawDekBase64,
}) {
  try {
    html.window.sessionStorage['$_dekPrefix$uid'] = rawDekBase64;
  } catch (_) {}
}

/// Retrieves the active DEK from browser sessionStorage for the current tab.
String? getSessionDek({required final String uid}) {
  try {
    return html.window.sessionStorage['$_dekPrefix$uid'];
  } catch (_) {
    return null;
  }
}

/// Saves the active recovery phrase in browser sessionStorage for the current tab.
void saveSessionPhrase({
  required final String uid,
  required final String phrase,
}) {
  try {
    html.window.sessionStorage['$_phrasePrefix$uid'] = phrase;
  } catch (_) {}
}

/// Retrieves the active recovery phrase from browser sessionStorage for the current tab.
String? getSessionPhrase({required final String uid}) {
  try {
    return html.window.sessionStorage['$_phrasePrefix$uid'];
  } catch (_) {
    return null;
  }
}

/// Clears all Pecunia keys from sessionStorage.
void clearSessionStorage() {
  try {
    final List<String> keysToRemove = html.window.sessionStorage.keys
        .where(
          (final String k) =>
              k.startsWith(_dekPrefix) || k.startsWith(_phrasePrefix),
        )
        .toList();
    for (final String k in keysToRemove) {
      html.window.sessionStorage.remove(k);
    }
  } catch (_) {}
}
