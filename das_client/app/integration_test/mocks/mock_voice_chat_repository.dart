import 'package:voice_chat/component.dart';

class MockVoiceChatRepository implements VoiceChatRepository {
  VoiceSession _session = const VoiceSession(permission: MicPermission.granted);

  @override
  VoiceSession get current => _session;

  @override
  Stream<VoiceSession> get session => const Stream.empty();

  @override
  Future<void> connect(VoiceRoomKey key) async {
    _session = _session.copyWith(roomKey: key, connection: VoiceConnectionState.connected);
  }

  @override
  Future<void> disconnect() async {
    _session = _session.copyWith(connection: VoiceConnectionState.disconnected);
  }

  @override
  Future<void> setMuted(bool muted) async {
    _session = _session.copyWith(isMuted: muted);
  }

  @override
  Future<void> requestMicrophonePermission() async {}

  @override
  Future<void> refreshMicrophonePermission() async {}

  @override
  void dispose() {}

  @override
  bool get isEnabled => false;
}
