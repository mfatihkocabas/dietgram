// TODO: Firebase will be enabled later for data storage
// import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
// import 'package:flutter/foundation.dart'
//     show defaultTargetPlatform, kIsWeb, TargetPlatform;

// Dummy FirebaseOptions class for compilation
class FirebaseOptions {
  const FirebaseOptions({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    this.authDomain,
    this.storageBucket,
    this.iosBundleId,
  });

  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  final String? authDomain;
  final String? storageBucket;
  final String? iosBundleId;
}

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
    // TODO: Uncomment when Firebase is configured
    /*
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    */
    throw UnsupportedError(
      'Firebase is not configured yet. Will be enabled in future updates.',
    );
  }

  // TODO: Configure these when Firebase is set up
  /*
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC8Q9fQ9fQ9fQ9fQ9fQ9fQ9fQ9fQ9fQ9fQ',
    appId: '1:123456789:web:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'dietgram-project',
    authDomain: 'dietgram-project.firebaseapp.com',
    storageBucket: 'dietgram-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC8Q9fQ9fQ9fQ9fQ9fQ9fQ9fQ9fQ9fQ9fQ',
    appId: '1:123456789:android:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'dietgram-project',
    storageBucket: 'dietgram-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC8Q9fQ9fQ9fQ9fQ9fQ9fQ9fQ9fQ9fQ9fQ',
    appId: '1:123456789:ios:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'dietgram-project',
    storageBucket: 'dietgram-project.appspot.com',
    iosBundleId: 'com.example.dietgram',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC8Q9fQ9fQ9fQ9fQ9fQ9fQ9fQ9fQ9fQ9fQ',
    appId: '1:123456789:macos:abcdef123456789',
    messagingSenderId: '123456789',
    projectId: 'dietgram-project',
    storageBucket: 'dietgram-project.appspot.com',
    iosBundleId: 'com.example.dietgram',
  );
  */
} 