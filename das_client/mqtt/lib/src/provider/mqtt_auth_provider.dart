abstract interface class MqttAuthProvider._() {
  Future<String> token();

  Future<String> userId();

  Future<String?> tid();

  String get oauthProfile;
}
