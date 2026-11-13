import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:voice_chat/src/token/token_provider.dart';
import 'package:voice_chat/src/token/access_token.dart';
import 'package:voice_chat/component.dart';

class DevTokenProvider implements TokenProvider {
  const DevTokenProvider({required this.apiKey, required this.apiSecret});

  final String apiKey;
  final String apiSecret;

  @override
  Future<AccessToken> getToken(VoiceRoomKey room, String identity) async {
    const validity = Duration(hours: 2);
    final jwt = JWT(
      {
        'name': identity,
        'video': {
          'room': room.value,
          'roomJoin': true,
          'canPublish': true,
          'canSubscribe': true,
        },
      },
      issuer: apiKey,
      subject: identity,
    );
    final token = jwt.sign(SecretKey(apiSecret), algorithm: JWTAlgorithm.HS256, expiresIn: validity);
    return AccessToken(jwt: token, expiresAt: DateTime.now().add(validity));
  }
}
