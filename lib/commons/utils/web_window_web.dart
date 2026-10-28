// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

void openInNewTab(final String routePath) {
  final String href = html.window.location.href;
  final String origin = html.window.location.origin;
  final bool hasHash = href.contains('#');

  final String targetUrl = hasHash
      ? '$origin/#$routePath'
      : '$origin$routePath';
  html.window.open(targetUrl, '_blank');
}
