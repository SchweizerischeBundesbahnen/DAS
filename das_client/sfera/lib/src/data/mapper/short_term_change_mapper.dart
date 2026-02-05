import 'package:logging/logging.dart';
import 'package:sfera/src/data/dto/end_destination_change_nsp_dto.dart';
import 'package:sfera/src/data/dto/enums/stop_pass_change_type_dto.dart';
import 'package:sfera/src/data/dto/general_jp_information_dto.dart';
import 'package:sfera/src/data/dto/stop_2_pass_or_pass_2_stop_nsp_dto.dart';
import 'package:sfera/src/data/dto/train_run_rerouting_nsp_dto.dart';
import 'package:sfera/src/model/journey/service_point.dart';
import 'package:sfera/src/model/journey/short_term_change.dart';

final _log = Logger('ShortTermChangeMapper');

class ShortTermChangeMapper {
  static Iterable<ShortTermChange> map(
    GeneralJpInformationDto? generalJpInformation,
    List<ServicePoint> servicePoints,
  ) {
    final locationCodeToServicePoint = {for (final sP in servicePoints) sP.locationCode: sP};
    final result = <ShortTermChange>[];

    for (final endDestinationChange
        in generalJpInformation?.endDestinationChangeNsps ?? <EndDestinationChangeNspDto>[]) {
      final startData = locationCodeToServicePoint[endDestinationChange.newLocationCode];
      if (startData == null) {
        _log.warning('Skipping $endDestinationChange - No service point found!');
        continue;
      }
      result.add(EndDestinationChange(startOrder: startData.order, endOrder: startData.order, startData: startData));
    }

    for (final stop2PassChange in generalJpInformation?.stop2PassOrPass2StopNsps ?? <Stop2PassOrPass2StopNspDto>[]) {
      for (final change in stop2PassChange.xmlStop2PassOrPass2Stop.element.changes) {
        final startData = locationCodeToServicePoint[change.modifiedOPLocationCode];
        if (startData == null) {
          _log.warning('Skipping $change - No service point found!');
          continue;
        }
        final shortTermChange = change.changeType == StopPassChangeTypeDto.pass2Stop
            ? Pass2StopChange(startOrder: startData.order, endOrder: startData.order, startData: startData)
            : Stop2PassChange(startOrder: startData.order, endOrder: startData.order, startData: startData);

        result.add(shortTermChange);
      }
    }

    for (final trainRunRerouting in generalJpInformation?.trainRunReroutingNsps ?? <TrainRunReroutingNspDto>[]) {
      for (final change in trainRunRerouting.xmlTrainRunRerouting.element.changes) {
        final startData = locationCodeToServicePoint[change.newRouteLocationCodes.first];
        if (startData == null) {
          _log.warning('Skipping $change - No service point found for start data!');
          continue;
        }
        final endData = locationCodeToServicePoint[change.newRouteLocationCodes.last];
        if (endData == null) {
          _log.warning('Skipping $change - No service point found for end data!');
          continue;
        }
        result.add(TrainRunReroutingChange(startOrder: startData.order, endOrder: endData.order, startData: startData));
      }
    }

    return result;
  }
}
