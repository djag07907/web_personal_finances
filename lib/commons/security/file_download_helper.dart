import 'package:web_personal_finances/commons/security/file_download_stub.dart'
    if (dart.library.html) 'package:web_personal_finances/commons/security/file_download_web.dart'
    as platform;

/// Downloads a text file to the user's browser/device downloads folder.
void downloadTextFile({
  required final String filename,
  required final String content,
}) {
  platform.downloadTextFile(filename: filename, content: content);
}
