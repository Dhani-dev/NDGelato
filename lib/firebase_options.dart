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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAjg3RNSvI_sP3Jlbhzd3oFYWf89SUgMgk',
    appId: '1:773865415476:web:b73337092adc3bb710fb61',
    messagingSenderId: '773865415476',
    projectId: 'ndgelato-71654',
    authDomain: 'ndgelato-71654.firebaseapp.com',
    storageBucket: 'ndgelato-71654.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBZ-0XVgTLHFuCCH_I1oDhxsFY7JmbRTGI',
    appId: '1:773865415476:android:9defef24a8623e2310fb61',
    messagingSenderId: '773865415476',
    projectId: 'ndgelato-71654',
    storageBucket: 'ndgelato-71654.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQAADUHfkVe239iWFrmB11GyojgpESXIU',
    appId: '1:773865415476:ios:d53569d03cd9450710fb61',
    messagingSenderId: '773865415476',
    projectId: 'ndgelato-71654',
    storageBucket: 'ndgelato-71654.firebasestorage.app',
    iosBundleId: 'com.example.ndGelato',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAQAADUHfkVe239iWFrmB11GyojgpESXIU',
    appId: '1:773865415476:ios:d53569d03cd9450710fb61',
    messagingSenderId: '773865415476',
    projectId: 'ndgelato-71654',
    storageBucket: 'ndgelato-71654.firebasestorage.app',
    iosBundleId: 'com.example.ndGelato',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAjg3RNSvI_sP3Jlbhzd3oFYWf89SUgMgk',
    appId: '1:773865415476:web:b8cc69fd1969075110fb61',
    messagingSenderId: '773865415476',
    projectId: 'ndgelato-71654',
    authDomain: 'ndgelato-71654.firebaseapp.com',
    storageBucket: 'ndgelato-71654.firebasestorage.app',
  );
}
