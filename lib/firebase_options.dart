import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBghmDfdT0nqCugp1Q0hQQyVIbqRgMudsM",
    authDomain: "equily-d6d90.firebaseapp.com",
    projectId: "equily-d6d90",
    storageBucket: "equily-d6d90.firebasestorage.app",
    messagingSenderId: "411007145175",
    appId: "1:411007145175:web:621e334cfd17335dfd8c92",
    measurementId: "G-PZEJHH53CD",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBghmDfdT0nqCugp1Q0hQQyVIbqRgMudsM",
    authDomain: "equily-d6d90.firebaseapp.com",
    projectId: "equily-d6d90",
    storageBucket: "equily-d6d90.firebasestorage.app",
    messagingSenderId: "411007145175",
    appId: "1:411007145175:android:621e334cfd17335dfd8c92",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyBghmDfdT0nqCugp1Q0hQQyVIbqRgMudsM",
    authDomain: "equily-d6d90.firebaseapp.com",
    projectId: "equily-d6d90",
    storageBucket: "equily-d6d90.firebasestorage.app",
    messagingSenderId: "411007145175",
    appId: "1:411007145175:ios:621e334cfd17335dfd8c92",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyBghmDfdT0nqCugp1Q0hQQyVIbqRgMudsM",
    authDomain: "equily-d6d90.firebaseapp.com",
    projectId: "equily-d6d90",
    storageBucket: "equily-d6d90.firebasestorage.app",
    messagingSenderId: "411007145175",
    appId: "1:411007145175:macos:621e334cfd17335dfd8c92",
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "AIzaSyBghmDfdT0nqCugp1Q0hQQyVIbqRgMudsM",
    authDomain: "equily-d6d90.firebaseapp.com",
    projectId: "equily-d6d90",
    storageBucket: "equily-d6d90.firebasestorage.app",
    messagingSenderId: "411007145175",
    appId: "1:411007145175:windows:621e334cfd17335dfd8c92",
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: "AIzaSyBghmDfdT0nqCugp1Q0hQQyVIbqRgMudsM",
    authDomain: "equily-d6d90.firebaseapp.com",
    projectId: "equily-d6d90",
    storageBucket: "equily-d6d90.firebasestorage.app",
    messagingSenderId: "411007145175",
    appId: "1:411007145175:linux:621e334cfd17335dfd8c92",
  );
}
