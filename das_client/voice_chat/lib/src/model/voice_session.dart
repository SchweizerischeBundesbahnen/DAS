import 'package:voice_chat/src/model/mic_permission.dart';
import 'package:voice_chat/src/model/voice_connection_state.dart';
import 'package:voice_chat/src/model/voice_error.dart';
import 'package:voice_chat/src/model/voice_participant.dart';
import 'package:voice_chat/src/model/voice_room_key.dart';

class VoiceSession {
  const VoiceSession({
    this.roomKey,
    this.connection = VoiceConnectionState.disconnected,
    this.isMuted = false,
    this.participants = const [],
    this.permission = MicPermission.unknown,
    this.error,
  });

  const VoiceSession.initial() : this();

  final VoiceRoomKey? roomKey;
  final VoiceConnectionState connection;
  final bool isMuted;
  final List<VoiceParticipant> participants;
  final MicPermission permission;
  final VoiceError? error;

  VoiceSession copyWith({
    VoiceRoomKey? roomKey,
    bool clearRoomKey = false,
    VoiceConnectionState? connection,
    bool? isMuted,
    List<VoiceParticipant>? participants,
    MicPermission? permission,
    VoiceError? error,
    bool clearError = false,
  }) {
    return VoiceSession(
      roomKey: clearRoomKey ? null : (roomKey ?? this.roomKey),
      connection: connection ?? this.connection,
      isMuted: isMuted ?? this.isMuted,
      participants: participants ?? this.participants,
      permission: permission ?? this.permission,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceSession &&
          roomKey == other.roomKey &&
          connection == other.connection &&
          isMuted == other.isMuted &&
          _sameParticipants(participants, other.participants) &&
          permission == other.permission &&
          error == other.error;

  @override
  int get hashCode => Object.hash(
    roomKey,
    connection,
    isMuted,
    Object.hashAll(participants),
    permission,
    error,
  );
}

bool _sameParticipants(List<VoiceParticipant> a, List<VoiceParticipant> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
