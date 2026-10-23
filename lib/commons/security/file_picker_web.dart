import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Prompts the user with a browser file picker to select a text (.txt) file
/// and returns its raw string contents.
Future<String?> pickTextFile() async {
  final html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
    ..accept = '.txt';
  uploadInput.click();

  final Completer<String?> completer = Completer<String?>();

  uploadInput.onChange.listen((final html.Event e) {
    final List<html.File>? files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final html.FileReader reader = html.FileReader();
      reader.readAsText(files.first);
      reader.onLoadEnd.listen((final html.ProgressEvent pe) {
        final Object? result = reader.result;
        if (result is String) {
          completer.complete(result);
        } else {
          completer.complete(null);
        }
      });
    } else {
      completer.complete(null);
    }
  });

  return completer.future;
}
