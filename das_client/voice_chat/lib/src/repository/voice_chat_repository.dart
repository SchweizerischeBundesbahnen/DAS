import 'package:voice_chat/component.dart';
import 'package:voice_chat/src/user_id_provider/user_id_provider_voice_chat.dart';

abstract class VoiceChatRepository({required UserIdProviderVoiceChat userIdProvider}) {
  Stream<VoiceSession> get session;

  VoiceSession get current;

  Future<void> connect(VoiceRoomKey key);

  Future<void> setMuted(bool muted);

  Future<void> disconnect();

  void dispose();
}
