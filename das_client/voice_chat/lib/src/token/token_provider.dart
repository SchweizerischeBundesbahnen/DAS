import 'package:voice_chat/component.dart';
import 'package:voice_chat/src/token/access_token.dart';

abstract class TokenProvider {
  Future<AccessToken> getToken(VoiceRoomKey room, String identity);
}
