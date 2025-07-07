import 'package:logging/logging.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/graduated_speed_info_dto.dart';
import 'package:sfera/src/data/dto/jp_context_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/new_speed_nsp_dto.dart';
import 'package:sfera/src/data/dto/velocity_dto.dart';

final _log = Logger('GraduatedSpeedDataMapper');

/// Used to map data from SFERA to domain model [SpeedData].
class SpeedMapper {
  SpeedMapper._();

  /// Maps list of SFERA model [VelocityDto] to [SpeedData]
  static List<TrainSeriesSpeed>? fromVelocities(Iterable<VelocityDto>? velocities) {
    if (velocities == null) return null;

    final result = <TrainSeriesSpeed>[];

    void addSpeed(TrainSeries trainSeries, int? breakSeries, String speedString, bool reduced) {
      try {
        final speeds = TrainSeriesSpeed(
          trainSeries: trainSeries,
          speed: Speed.parse(speedString),
          breakSeries: breakSeries,
          reduced: reduced,
        );
        result.add(speeds);
      } catch (e) {
        _log.warning('Could not parse speed with "$speedString"', e);
      }
    }

    for (final velocity in velocities) {
      if (velocity.speed != null) {
        addSpeed(velocity.trainSeries, velocity.brakeSeries, velocity.speed!, velocity.reduced);
      }
    }

    return result;
  }

  /// Maps SFERA model [GraduatedSpeedInfoDto] to [SpeedData]
  static List<TrainSeriesSpeed>? fromGraduatedSpeedInfo(GraduatedSpeedInfoDto? graduatedSpeedInfo) {
    if (graduatedSpeedInfo == null) return null;

    final result = <TrainSeriesSpeed>[];

    void addSpeed(TrainSeries trainSeries, String speedString, String? text) {
      try {
        final speeds = TrainSeriesSpeed(trainSeries: trainSeries, speed: Speed.parse(speedString), text: text);
        result.add(speeds);
      } catch (e) {
        _log.warning('Could not parse graduated station speed info with "$speedString"', e);
      }
    }

    for (final entity in graduatedSpeedInfo.entities) {
      if (entity.adSpeed != null) {
        addSpeed(TrainSeries.A, entity.adSpeed!, entity.text);
        addSpeed(TrainSeries.D, entity.adSpeed!, entity.text);
      }
      if (entity.nSpeed != null) {
        addSpeed(TrainSeries.N, entity.nSpeed!, entity.text);
      }
      if (entity.sSpeed != null) {
        addSpeed(TrainSeries.S, entity.sSpeed!, entity.text);
      }
      if (entity.roSpeed != null) {
        addSpeed(TrainSeries.R, entity.roSpeed!, entity.text);
        addSpeed(TrainSeries.O, entity.roSpeed!, entity.text);
      }
    }

    return result;
  }

  static SingleSpeed? fromJourneyProfileContextInfoNsp(JpContextInformationNspDto? jpContextInfoNsp) {
    if (jpContextInfoNsp == null) return null;

    final nsp = jpContextInfoNsp.parameters.firstOrNull;
    if (nsp is! NewSpeedNetworkSpecificParameterDto) return null;

    return SingleSpeed(value: nsp.speed);
  }
}
