import 'package:app/auth/authentication_component.dart';
import 'package:app/mqtt/mqtt_component.dart';
import 'package:app/sfera/src/db/repo/sfera_database_repository.dart';
import 'package:app/sfera/src/db/repo/sfera_database_repository_impl.dart';
import 'package:app/sfera/src/service/local/sfera_local_service.dart';
import 'package:app/sfera/src/service/local/sfera_local_service_impl.dart';
import 'package:app/sfera/src/service/remote/sfera_auth_service.dart';
import 'package:app/sfera/src/service/remote/sfera_auth_service_impl.dart';
import 'package:app/sfera/src/service/remote/sfera_service.dart';
import 'package:app/sfera/src/service/remote/sfera_service_impl.dart';

export 'package:app/sfera/src/db/repo/sfera_database_repository.dart';
export 'package:app/sfera/src/model/otn_id.dart';
export 'package:app/sfera/src/service/local/sfera_local_service.dart';
export 'package:app/sfera/src/service/remote/sfera_auth_service.dart';
export 'package:app/sfera/src/service/remote/sfera_service.dart';
export 'package:app/sfera/src/service/remote/sfera_service_state.dart';
export 'package:app/sfera/src/sfera_reply_parser.dart';

class SferaComponent {
  const SferaComponent._();

  static SferaDatabaseRepository createDatabaseRepository() {
    return SferaDatabaseRepositoryImpl();
  }

  static SferaAuthService createSferaAuthService({
    required Authenticator authenticator,
    required String tokenExchangeUrl,
  }) {
    return SferaAuthServiceImpl(authenticator: authenticator, tokenExchangeUrl: tokenExchangeUrl);
  }

  static SferaService createSferaService({
    required MqttService mqttService,
    required SferaDatabaseRepository sferaDatabaseRepository,
    required Authenticator authenticator,
  }) {
    return SferaServiceImpl(
        mqttService: mqttService, sferaDatabaseRepository: sferaDatabaseRepository, authenticator: authenticator);
  }

  static SferaLocalService createSferaLocalService({required SferaDatabaseRepository sferaDatabaseRepository}) {
    return SferaLocalServiceImpl(sferaDatabaseRepository: sferaDatabaseRepository);
  }
}
