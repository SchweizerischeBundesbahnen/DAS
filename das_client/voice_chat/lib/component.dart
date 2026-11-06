import 'package:logging/logging.dart';
import 'package:voice_chat/constants_dev/constants.dart';
import 'package:voice_chat/src/mic_permission/permission_service.dart';
import 'package:voice_chat/src/repository/voice_chat_repository.dart';
import 'package:voice_chat/src/repository/voice_chat_repository_impl.dart';
import 'package:voice_chat/src/token/dev_token_provider.dart';
import 'package:voice_chat/src/user_id_provider/user_id_provider_voice_chat.dart';

export 'package:voice_chat/src/repository/voice_chat_repository.dart';
export 'package:voice_chat/src/model/voice_room_key.dart';
export 'package:voice_chat/src/user_id_provider/user_id_provider_voice_chat.dart';
export 'package:voice_chat/src/model/voice_session.dart';
export 'package:voice_chat/src/model/voice_participant.dart';
export 'package:voice_chat/src/model/voice_connection_state.dart';
export 'package:voice_chat/src/model/mic_permission.dart';
export 'package:voice_chat/src/model/voice_error.dart';
export 'package:voice_chat/src/pulsar_haptics_voice_chat/pulsar_haptics_voice_chat.dart';

final _log = Logger('VoiceChatComponent');

class VoiceChatComponent._() {
  /// Suppresses the startup microphone permission request.
  /// A test that specifically exercises the microphone permission flow can leave
  /// it `false` (or reset it) to request the permission as the real app would.
  static bool suppressMicrophonePermissionRequest = false;

  static Future<void> requestMicrophonePermission() async {
    if (suppressMicrophonePermissionRequest) {
      _log.info('Microphone permission request suppressed');
      return;
    }
    await PermissionService().requestMicrophone();
  }

  static VoiceChatRepository createRepository({required UserIdProviderVoiceChat userIdProvider}) {
    return VoiceChatRepositoryImpl(
      userIdProvider: userIdProvider,
      liveKitUrl: livekitUrl,
      tokenProvider: DevTokenProvider(apiKey: livekitApiKey, apiSecret: livekitApiSecret),
      permissionService: PermissionService(),
    );
  }
}
