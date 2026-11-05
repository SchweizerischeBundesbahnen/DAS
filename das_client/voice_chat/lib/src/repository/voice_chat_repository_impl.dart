import 'dart:async';

import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';
import 'package:voice_chat/component.dart';
import 'package:voice_chat/src/mic_permission/permission_service.dart';
import 'package:voice_chat/src/token/token_provider.dart';

final _log = Logger('VoiceChatRepositoryImpl');

class VoiceChatRepositoryImpl({
  required this.userIdProvider,
  required this.liveKitUrl,
  required this.tokenProvider,
  required this.permissionService,
}) implements VoiceChatRepository {
  final String liveKitUrl;
  final TokenProvider tokenProvider;
  final UserIdProviderVoiceChat userIdProvider;
  final PermissionService permissionService;

  final _controller = StreamController<VoiceSession>.broadcast();
  VoiceSession _session = VoiceSession.initial();
  Room? _room;
  EventsListener<RoomEvent>? _listener;

  @override
  Stream<VoiceSession> get session => _controller.stream;

  @override
  VoiceSession get current => _session;

  @override
  Future<void> connect(VoiceRoomKey key) async {
    _log.info('Connecting to room ${key.value} at $liveKitUrl');
    try {
      await disconnect();
      _emit(_session.copyWith(roomKey: key, connection: VoiceConnectionState.connecting, clearError: true));

      if (_session.permission == MicPermission.unknown) {
        await refreshMicrophonePermission();
      }
      if (_session.permission != MicPermission.granted) {
        _log.warning('Microphone permission is ${_session.permission}, not joining room ${key.value}');
        _fail(VoiceError.permissionDenied);
        return;
      }

      if (liveKitUrl.isEmpty) {
        _log.severe('LiveKit URL is empty. Was --dart-define-from-file passed?');
        _fail(VoiceError.serverUnreachable);
        return;
      }

      final identity = await userIdProvider.call();

      final token = await tokenProvider.getToken(key, identity); // Token nie loggen (NFA4)
      _log.fine('Received token for room ${key.value} as $identity');

      final room = Room();
      _room = room;
      room.addListener(_sync);
      _listener = room.createListener()..on<RoomDisconnectedEvent>((e) => _onDisconnected(e.reason));

      await room.connect(liveKitUrl, token.jwt);
      _log.info('Connected to room ${key.value}');
      PulsarHapticsVoiceChat().playPreset('connect');

      await room.localParticipant?.setMicrophoneEnabled(!_session.isMuted);
      _log.fine('Microphone enabled: ${!_session.isMuted}');
      _sync();
    } on ConnectException catch (e, stackTrace) {
      _log.severe('Failed to connect to room ${key.value}: ${e.reason}', e, stackTrace);
      await _releaseRoom();
      _fail(e.reason == ConnectionErrorReason.NotAllowed ? VoiceError.tokenInvalid : VoiceError.serverUnreachable);
    } catch (e, stackTrace) {
      _log.severe('Failed to connect to room ${key.value}', e, stackTrace);
      await _releaseRoom();
      _fail(VoiceError.unknown);
    }
  }

  @override
  Future<void> disconnect() async {
    if (_room == null) return;
    _log.info('Leaving room ${_session.roomKey?.value}');
    await _releaseRoom();
    PulsarHapticsVoiceChat().playPreset('disconnect');
    _emit(
      _session.copyWith(
        connection: VoiceConnectionState.disconnected,
        participants: const [],
        clearRoomKey: true,
      ),
    );
  }

  @override
  Future<void> setMuted(bool muted) async {
    try {
      await _room?.localParticipant?.setMicrophoneEnabled(!muted);
    } catch (e, stackTrace) {
      _log.severe('Failed to set microphone muted=$muted', e, stackTrace);
      _fail(VoiceError.unknown);
      return;
    }
    _emit(_session.copyWith(isMuted: muted));
  }

  @override
  Future<void> requestMicrophonePermission() async {
    final permission = await permissionService.requestMicrophone();
    _applyPermission(permission);
  }

  @override
  Future<void> refreshMicrophonePermission() async {
    final permission = await permissionService.microphoneStatus();
    if (permission == _session.permission) return;
    _applyPermission(permission);
  }

  @override
  void dispose() {
    unawaited(_releaseRoom().whenComplete(_controller.close));
  }

  void _applyPermission(MicPermission permission) {
    _log.fine('Microphone permission: $permission');
    final clearOldError = permission == MicPermission.granted && _session.error == VoiceError.permissionDenied;
    _emit(_session.copyWith(permission: permission, clearError: clearOldError));
  }

  /// Räumt den Room auf, ohne einen neuen Zustand zu emittieren.
  Future<void> _releaseRoom() async {
    final room = _room;
    _room = null;
    if (room == null) return;
    room.removeListener(_sync);
    await _listener?.dispose();
    _listener = null;
    try {
      await room.disconnect();
    } catch (e, stackTrace) {
      _log.warning('Error while disconnecting room', e, stackTrace);
    }
    await room.dispose();
  }

  void _sync() {
    final room = _room;
    if (room == null) return;
    final all = <Participant>[
      if (room.localParticipant != null) room.localParticipant!,
      ...room.remoteParticipants.values,
    ];
    _emit(
      _session.copyWith(
        connection: _map(room.connectionState),
        participants: all
            .map(
              (p) => VoiceParticipant(
                identity: p.identity,
                isLocal: p is LocalParticipant,
                isMuted: p.isMuted,
                isSpeaking: p.isSpeaking,
              ),
            )
            .toList(),
      ),
    );
  }

  VoiceConnectionState _map(ConnectionState s) => switch (s) {
    ConnectionState.disconnected => VoiceConnectionState.disconnected,
    ConnectionState.connecting => VoiceConnectionState.connecting,
    ConnectionState.reconnecting => VoiceConnectionState.reconnecting,
    ConnectionState.connected => VoiceConnectionState.connected,
  };

  void _onDisconnected(DisconnectReason? reason) {
    _log.info('Disconnected from room ${_session.roomKey?.value}: $reason');
    switch (reason) {
      case null:
      case DisconnectReason.clientInitiated:
        return;
      case DisconnectReason.duplicateIdentity:
        _fail(VoiceError.duplicateIdentity);
      case DisconnectReason.serverShutdown:
        _fail(VoiceError.serverUnreachable);
      default:
        _fail(VoiceError.unknown);
    }
  }

  void _fail(VoiceError error) {
    _log.warning('Voice chat error: $error');
    _emit(_session.copyWith(connection: VoiceConnectionState.failed, error: error));
  }

  void _emit(VoiceSession s) {
    _session = s;
    if (_controller.isClosed) return;
    _controller.add(s);
  }
}
