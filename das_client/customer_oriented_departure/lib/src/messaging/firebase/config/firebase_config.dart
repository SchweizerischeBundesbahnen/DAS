import 'dart:io' show Platform;

import 'package:customer_oriented_departure/component.dart';
import 'package:firebase_core/firebase_core.dart';

enum FirebaseConfig {
  development(
    FirebaseOptions(
      apiKey: 'AIzaSyC96OX9RhKzTwMZDFQbfhcIJ02_G-88CLU',
      appId: '1:451204056905:android:086bf269c7c2e099c73c98',
      messagingSenderId: '451204056905',
      projectId: 'gems-koa-das',
      storageBucket: 'gems-koa-das.firebasestorage.app',
    ),
    FirebaseOptions(
      apiKey: 'AIzaSyDTY1CqO0ihcJ5z6kP7p6GdLckr70j475I',
      appId: '1:451204056905:ios:8cf2f0cf4101547dc73c98',
      messagingSenderId: '451204056905',
      projectId: 'gems-koa-das',
      storageBucket: 'gems-koa-das.firebasestorage.app',
      iosClientId: '451204056905-uvfkc4pi6rh35us7e4s7esjpe7r810ob.apps.googleusercontent.com',
      iosBundleId: 'ch.sbb.das.dev',
    ),
  ),
  integration(
    FirebaseOptions(
      apiKey: 'AIzaSyC96OX9RhKzTwMZDFQbfhcIJ02_G-88CLU',
      appId: '1:451204056905:android:1df4e89d65128026c73c98',
      messagingSenderId: '451204056905',
      projectId: 'gems-koa-das',
      storageBucket: 'gems-koa-das.firebasestorage.app',
    ),
    FirebaseOptions(
      apiKey: 'AIzaSyDTY1CqO0ihcJ5z6kP7p6GdLckr70j475I',
      appId: '1:451204056905:ios:1011b37364e1ba66c73c98',
      messagingSenderId: '451204056905',
      projectId: 'gems-koa-das',
      storageBucket: 'gems-koa-das.firebasestorage.app',
      iosClientId: '451204056905-fd0u0upl518bcq0aje208p67e8ltcoe7.apps.googleusercontent.com',
      iosBundleId: 'ch.sbb.das.inte',
    ),
  ),
  production(
    FirebaseOptions(
      apiKey: 'AIzaSyC96OX9RhKzTwMZDFQbfhcIJ02_G-88CLU',
      appId: '1:451204056905:android:0cd7e563d6560211c73c98',
      messagingSenderId: '451204056905',
      projectId: 'gems-koa-das',
      storageBucket: 'gems-koa-das.firebasestorage.app',
    ),
    FirebaseOptions(
      apiKey: 'AIzaSyDTY1CqO0ihcJ5z6kP7p6GdLckr70j475I',
      appId: '1:451204056905:ios:2872bf8fa6efb318c73c98',
      messagingSenderId: '451204056905',
      projectId: 'gems-koa-das',
      storageBucket: 'gems-koa-das.firebasestorage.app',
      iosClientId: '451204056905-k7sbn0l8q2r9onm26185fj1oni2bu69u.apps.googleusercontent.com',
      iosBundleId: 'ch.sbb.das',
    ),
  );

  const FirebaseConfig(this._android, this._iOS);

  final FirebaseOptions _android;
  final FirebaseOptions _iOS;

  FirebaseOptions get options {
    if (Platform.isAndroid) {
      return _android;
    } else if (Platform.isIOS) {
      return _iOS;
    } else {
      throw UnsupportedError('Unsupported platform ${Platform.operatingSystem}');
    }
  }
}

extension CustomerOrientedDepartureEnvironmentX on CustomerOrientedDepartureEnvironment {
  FirebaseConfig toFirebaseConfig() => switch (this) {
    .dev => .development,
    .int => .integration,
    .prod => .production,
  };
}
