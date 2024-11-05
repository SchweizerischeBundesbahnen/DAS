import 'dart:core';

abstract class MqttService {
  MqttService._();

  Stream<String> get messageStream;

  void disconnect();

  Future<bool> connect(String company, String train);

  bool publishMessage(String company, String train, String message);
}
