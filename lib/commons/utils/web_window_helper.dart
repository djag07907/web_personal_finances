import 'package:web_personal_finances/commons/utils/web_window_stub.dart'
    if (dart.library.html) 'package:web_personal_finances/commons/utils/web_window_web.dart'
    as platform;

/// Opens the specified application route or URL in a new browser tab.
void openUrlInNewTab(final String routePath) {
  platform.openInNewTab(routePath);
}

