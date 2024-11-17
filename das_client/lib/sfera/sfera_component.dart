import 'package:das_client/auth/authentication_component.dart';
import 'package:das_client/mqtt/mqtt_component.dart';
import 'package:das_client/sfera/src/repo/sfera_repository.dart';
import 'package:das_client/sfera/src/repo/sfera_repository_impl.dart';
import 'package:das_client/sfera/src/service/sfera_auth_service.dart';
import 'package:das_client/sfera/src/service/sfera_service.dart';
import 'package:das_client/sfera/src/service/sfera_service_impl.dart';

export 'package:das_client/sfera/src/model/otn_id.dart';
export 'package:das_client/sfera/src/repo/sfera_repository.dart';
export 'package:das_client/sfera/src/service/sfera_auth_service.dart';
export 'package:das_client/sfera/src/service/sfera_service.dart';
export 'package:das_client/sfera/src/service/sfera_service_state.dart';
export 'package:das_client/sfera/src/sfera_reply_parser.dart';

class SferaComponent {
  const SferaComponent._();

  static SferaRepository createRepository() {
    return SferaRepositoryImpl();
  }

  static SferaAuthService createSferaAuthService(
      {required Authenticator authenticator, required String tokenExchangeUrl}) {
    return SferaAuthService(authenticator: authenticator, tokenExchangeUrl: tokenExchangeUrl);
  }

  static SferaService createSferaService({required MqttService mqttService, required SferaRepository sferaRepository, required Authenticator authenticator}) {
    return SferaServiceImpl(mqttService: mqttService, sferaRepository: sferaRepository, authenticator: authenticator);
  }
}
