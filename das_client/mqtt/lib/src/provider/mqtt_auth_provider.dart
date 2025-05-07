abstract interface class MqttAuthProvider {
  const MqttAuthProvider._();

  Future<String> token();

  Future<String?> tmsToken({required String company, required String train, required String role});

  Future<String?> userId();
}
