import 'package:json_annotation/json_annotation.dart';
import 'package:voice_chat/component.dart';
import 'package:meta/meta.dart';

@immutable
@JsonSerializable()
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
