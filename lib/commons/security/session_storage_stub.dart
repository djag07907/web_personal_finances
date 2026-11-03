/// Non-web fallback for sessionStorage.
void saveSessionDek({
  required final String uid,
  required final String rawDekBase64,
}) {}

String? getSessionDek({required final String uid}) => null;

void saveSessionPhrase({
  required final String uid,
  required final String phrase,
}) {}

String? getSessionPhrase({required final String uid}) => null;

void clearSessionStorage() {}
