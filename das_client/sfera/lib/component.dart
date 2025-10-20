import 'package:http_x/component.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/src/data/api/sfera_auth_service.dart';
import 'package:sfera/src/data/api/sfera_auth_service_impl.dart';
import 'package:sfera/src/data/local/drift_local_database_service.dart';
import 'package:sfera/src/data/repository/sfera_local_repo.dart';
import 'package:sfera/src/data/repository/sfera_local_repo_impl.dart';
import 'package:sfera/src/data/repository/sfera_remote_repo.dart';
import 'package:sfera/src/data/repository/sfera_remote_repo_impl.dart';
import 'package:sfera/src/provider/sfera_auth_provider.dart';

export 'package:sfera/src/data/api/sfera_auth_service.dart';
export 'package:sfera/src/data/api/sfera_error.dart';
export 'package:sfera/src/data/parser/sfera_reply_parser.dart';
export 'package:sfera/src/data/repository/sfera_local_repo.dart';
export 'package:sfera/src/data/repository/sfera_remote_repo.dart';
export 'package:sfera/src/data/repository/sfera_remote_repo_state.dart';
export 'package:sfera/src/model/journey/additional_speed_restriction.dart';
export 'package:sfera/src/model/journey/additional_speed_restriction_data.dart';
export 'package:sfera/src/model/journey/advised_speed_segment.dart';
export 'package:sfera/src/model/journey/arrival_departure_time.dart';
export 'package:sfera/src/model/journey/balise.dart';
export 'package:sfera/src/model/journey/balise_level_crossing_group.dart';
export 'package:sfera/src/model/journey/base_data.dart';
export 'package:sfera/src/model/journey/base_data_extension.dart';
export 'package:sfera/src/model/journey/base_foot_note.dart';
export 'package:sfera/src/model/journey/bracket_station_segment.dart';
export 'package:sfera/src/model/journey/break_series.dart';
export 'package:sfera/src/model/journey/cab_signaling.dart';
export 'package:sfera/src/model/journey/combined_foot_note_operational_indication.dart';
export 'package:sfera/src/model/journey/communication_network_change.dart';
export 'package:sfera/src/model/journey/connection_track.dart';
export 'package:sfera/src/model/journey/contact.dart';
export 'package:sfera/src/model/journey/contact_list.dart';
export 'package:sfera/src/model/journey/curve_point.dart';
export 'package:sfera/src/model/journey/datatype.dart';
export 'package:sfera/src/model/journey/delay.dart';
export 'package:sfera/src/model/journey/foot_note.dart';
export 'package:sfera/src/model/journey/journey.dart';
export 'package:sfera/src/model/journey/journey_annotation.dart';
export 'package:sfera/src/model/journey/journey_point.dart';
export 'package:sfera/src/model/journey/koa_state.dart';
export 'package:sfera/src/model/journey/level_crossing.dart';
export 'package:sfera/src/model/journey/level_crossing_group.dart';
export 'package:sfera/src/model/journey/line_foot_note.dart';
export 'package:sfera/src/model/journey/local_regulation_section.dart';
export 'package:sfera/src/model/journey/metadata.dart';
export 'package:sfera/src/model/journey/op_foot_note.dart';
export 'package:sfera/src/model/journey/protection_section.dart';
export 'package:sfera/src/model/journey/segment.dart';
export 'package:sfera/src/model/journey/service_point.dart';
export 'package:sfera/src/model/journey/shunting_movement.dart';
export 'package:sfera/src/model/journey/signal.dart';
export 'package:sfera/src/model/journey/signaled_position.dart';
export 'package:sfera/src/model/journey/speed.dart';
export 'package:sfera/src/model/journey/speed_change.dart';
export 'package:sfera/src/model/journey/station_property.dart';
export 'package:sfera/src/model/journey/station_sign.dart';
export 'package:sfera/src/model/journey/supervised_level_crossing_group.dart';
export 'package:sfera/src/model/journey/track_equipment_segment.dart';
export 'package:sfera/src/model/journey/track_foot_note.dart';
export 'package:sfera/src/model/journey/train_series.dart';
export 'package:sfera/src/model/journey/train_series_speed.dart';
export 'package:sfera/src/model/journey/tram_area.dart';
export 'package:sfera/src/model/journey/uncoded_operational_indication.dart';
export 'package:sfera/src/model/journey/unsupervised_level_crossing_group.dart';
export 'package:sfera/src/model/journey/ux_testing_event.dart';
export 'package:sfera/src/model/journey/warnapp_event.dart';
export 'package:sfera/src/model/journey/whistles.dart';
export 'package:sfera/src/model/localized_string.dart';
export 'package:sfera/src/model/ru.dart';
export 'package:sfera/src/model/train_identification.dart';
export 'package:sfera/src/provider/sfera_auth_provider.dart';

class SferaComponent {
  const SferaComponent._();

  static SferaAuthService createSferaAuthService({
    required Client httpClient,
    required String tokenExchangeUrl,
  }) {
    return SferaAuthServiceImpl(httpClient: httpClient, tokenExchangeUrl: tokenExchangeUrl);
  }

  static SferaRemoteRepo createSferaRemoteRepo({
    required MqttService mqttService,
    required SferaAuthProvider sferaAuthProvider,
    required String deviceId,
  }) {
    final localDatabaseService = DriftLocalDatabaseService.instance;
    return SferaRemoteRepoImpl(
      mqttService: mqttService,
      localService: localDatabaseService,
      authProvider: sferaAuthProvider,
      deviceId: deviceId,
    );
  }

  static SferaLocalRepo createSferaLocalRepo() {
    final localDatabaseService = DriftLocalDatabaseService.instance;
    return SferaLocalRepoImpl(localService: localDatabaseService);
  }
}
