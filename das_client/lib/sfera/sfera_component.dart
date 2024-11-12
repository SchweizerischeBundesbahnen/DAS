import 'package:das_client/auth/authentication_component.dart';
import 'package:das_client/mqtt/mqtt_component.dart';
import 'package:das_client/sfera/src/repo/sfera_repository.dart';
import 'package:das_client/sfera/src/repo/sfera_repository_impl.dart';
import 'package:das_client/sfera/src/service/sfera_auth_service.dart';
import 'package:das_client/sfera/src/service/sfera_service.dart';
import 'package:das_client/sfera/src/service/sfera_service_impl.dart';

export 'package:das_client/sfera/src/model/b2g_request.dart';
export 'package:das_client/sfera/src/model/das_operating_modes_selected.dart';
export 'package:das_client/sfera/src/model/das_operating_modes_supported.dart';
export 'package:das_client/sfera/src/model/g2b_reply_payload.dart';
export 'package:das_client/sfera/src/model/handshake_acknowledgement.dart';
export 'package:das_client/sfera/src/model/handshake_reject.dart';
export 'package:das_client/sfera/src/model/handshake_request.dart';
export 'package:das_client/sfera/src/model/journey_profile.dart';
export 'package:das_client/sfera/src/model/jp_request.dart';
export 'package:das_client/sfera/src/model/message_header.dart';
export 'package:das_client/sfera/src/model/otn_id.dart';
export 'package:das_client/sfera/src/model/segment_profile.dart';
export 'package:das_client/sfera/src/model/segment_profile_list.dart';
export 'package:das_client/sfera/src/model/sfera_b2g_request_message.dart';
export 'package:das_client/sfera/src/model/sfera_g2b_reply_message.dart';
export 'package:das_client/sfera/src/model/sfera_xml_element.dart';
export 'package:das_client/sfera/src/model/signal.dart';
export 'package:das_client/sfera/src/model/signal_id.dart';
export 'package:das_client/sfera/src/model/sp_points.dart';
export 'package:das_client/sfera/src/model/sp_request.dart';
export 'package:das_client/sfera/src/model/sp_zone.dart';
export 'package:das_client/sfera/src/model/stopping_point_information.dart';
export 'package:das_client/sfera/src/model/timing_point.dart';
export 'package:das_client/sfera/src/model/timing_point_constraints.dart';
export 'package:das_client/sfera/src/model/timing_point_reference.dart';
export 'package:das_client/sfera/src/model/tp_id_reference.dart';
export 'package:das_client/sfera/src/model/tp_name.dart';
export 'package:das_client/sfera/src/model/train_identification.dart';
export 'package:das_client/sfera/src/model/virtual_balise.dart';
export 'package:das_client/sfera/src/model/virtual_balise_position.dart';
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
