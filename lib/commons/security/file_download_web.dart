import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

void downloadTextFile({
  required final String filename,
  required final String content,
}) {
  final List<int> bytes = utf8.encode(content);
  final html.Blob blob = html.Blob(<dynamic>[
    bytes,
  ], 'text/plain;charset=utf-8');
  final String url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
