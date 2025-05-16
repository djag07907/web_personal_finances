import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_personal_finances/resources/constants.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? emptyString,
      appId: dotenv.env['FIREBASE_APP_ID_WEB'] ?? emptyString,
      messagingSenderId:
          dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? emptyString,
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? emptyString,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? emptyString,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? emptyString,
    );
  }

  static FirebaseOptions get android {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? emptyString,
      appId: dotenv.env['FIREBASE_APP_ID_ANDROID'] ?? emptyString,
      messagingSenderId:
          dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? emptyString,
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? emptyString,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? emptyString,
    );
  }

  static FirebaseOptions get ios {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? emptyString,
      appId: dotenv.env['FIREBASE_APP_ID_IOS'] ?? emptyString,
      messagingSenderId:
          dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? emptyString,
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? emptyString,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? emptyString,
      iosBundleId: dotenv.env['FIREBASE_IOS_BUNDLE_ID'] ?? emptyString,
    );
  }
}
