abstract interface class MqttAuthProvider {
  const MqttAuthProvider._();

  Future<String> token();

  Future<String> userId();

  Future<String?> tid();

  String get oauthProfile;
}
