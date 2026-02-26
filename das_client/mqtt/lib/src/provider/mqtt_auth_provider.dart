import 'package:auth/component.dart';

abstract interface class MqttAuthProvider {
  const MqttAuthProvider._();

  Future<String> token();

  Future<User> user();

  String get oauthProfile;
}
