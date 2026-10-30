import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_personal_finances/commons/error/privacy_safe_logger.dart';

/// Service responsible for managing Firebase App Check device/domain attestation.
/// Protects Firestore and Firebase Auth against automated bots, abuse, and scraping.
class AppCheckService {
  AppCheckService._();

  /// Initializes Firebase App Check.
  /// On Web: Uses ReCaptchaV3Provider using RECAPTCHA_V3_SITE_KEY from .env.
  /// In debug mode or if no site key is supplied, gracefully bypasses to allow localhost development.
  static Future<void> initialize() async {
    try {
      final String? webSiteKey = dotenv.env['RECAPTCHA_V3_SITE_KEY'] ??
          dotenv.env['RECAPTCHA_SITE_KEY'];

      if (kIsWeb) {
        if (webSiteKey != null && webSiteKey.isNotEmpty) {
          await FirebaseAppCheck.instance.activate(
            providerWeb: ReCaptchaV3Provider(webSiteKey),
          );
          if (kDebugMode) {
            debugPrint('[AppCheck] ReCaptchaV3Provider activated.');
          }
        } else if (kDebugMode) {
          debugPrint(
            '[AppCheck] Note: No RECAPTCHA_SITE_KEY found in .env; skipping App Check on localhost debug.',
          );
        }
      } else {
        await FirebaseAppCheck.instance.activate(
          providerAndroid: kDebugMode
              ? const AndroidDebugProvider()
              : const AndroidPlayIntegrityProvider(),
          providerApple: kDebugMode
              ? const AppleDebugProvider()
              : const AppleDeviceCheckProvider(),
        );
      }
    } catch (error, stackTrace) {
      PrivacySafeLogger.logError(error, stackTrace, 'AppCheckService.initialize');
    }
  }
}
