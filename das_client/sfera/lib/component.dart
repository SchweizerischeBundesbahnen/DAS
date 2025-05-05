import 'package:auth/component.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/src/data/local/db/repo/sfera_database_repository.dart';
import 'package:sfera/src/data/local/db/repo/sfera_database_repository_impl.dart';
import 'package:sfera/src/data/local/sfera_local_service.dart';
import 'package:sfera/src/data/local/sfera_local_service_impl.dart';
import 'package:sfera/src/data/sfera_api/sfera_auth_service.dart';
import 'package:sfera/src/data/sfera_api/sfera_auth_service_impl.dart';
import 'package:sfera/src/data/sfera_api/sfera_service.dart';
import 'package:sfera/src/data/sfera_api/sfera_service_impl.dart';

export 'package:sfera/src/data/local/db/repo/sfera_database_repository.dart';
export 'package:sfera/src/data/dto/otn_id.dart';
export 'package:sfera/src/data/local/sfera_local_service.dart';
export 'package:sfera/src/data/sfera_api/sfera_auth_service.dart';
export 'package:sfera/src/data/sfera_api/sfera_service.dart';
export 'package:sfera/src/data/sfera_api/sfera_service_state.dart';
export 'package:sfera/src/data/mapper/sfera_reply_parser.dart';
export 'package:sfera/src/data/sfera_api/sfera_error.dart';

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
