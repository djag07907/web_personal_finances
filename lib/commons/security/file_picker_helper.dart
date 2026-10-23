import 'package:web_personal_finances/commons/security/file_picker_stub.dart'
    if (dart.library.html) 'package:web_personal_finances/commons/security/file_picker_web.dart'
    as platform;

/// Prompts the user to pick a text file and returns its content as a String.
Future<String?> pickTextFile() => platform.pickTextFile();
