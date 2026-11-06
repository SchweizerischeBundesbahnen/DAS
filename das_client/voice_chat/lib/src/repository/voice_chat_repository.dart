import 'package:voice_chat/src/model/voice_room_key.dart';
import 'package:voice_chat/src/model/voice_session.dart';

abstract class VoiceChatRepository {
  bool get isEnabled;

  Stream<VoiceSession> get session;

  VoiceSession get current;

  Future<void> connect(VoiceRoomKey key);

  Future<void> setMuted(bool muted);

  Future<void> disconnect();

  Future<void> requestMicrophonePermission();

  Future<void> refreshMicrophonePermission();

  void dispose();
}
