// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCIU8zJsXd2KpvSZDwtPyeNfc4djQuwv_0',
    appId: '1:592895656758:android:819864ae35e342f26f2997',
    messagingSenderId: '592895656758',
    projectId: 'workings-688c0',
    storageBucket: 'workings-688c0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8jXDfjtN6GV1yHkuyEu930EMg4xCKpqg',
    appId: '1:592895656758:ios:1b4699094b7c72706f2997',
    messagingSenderId: '592895656758',
    projectId: 'workings-688c0',
    storageBucket: 'workings-688c0.firebasestorage.app',
    androidClientId: '592895656758-aqk5f43rl016lsuerv50gfmnfofmjg90.apps.googleusercontent.com',
    iosClientId: '592895656758-fbjq3tm3bvppfb1a1kgiukt7poe54upg.apps.googleusercontent.com',
    iosBundleId: 'com.workings.proapp',
  );

}