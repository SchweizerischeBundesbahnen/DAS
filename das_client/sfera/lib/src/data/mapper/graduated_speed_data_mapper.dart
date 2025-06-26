import 'package:logging/logging.dart';
import 'package:sfera/src/data/dto/graduated_speed_info_dto.dart';
import 'package:sfera/src/data/dto/velocity_dto.dart';
import 'package:sfera/src/model/journey/speed_data.dart';
import 'package:sfera/src/model/journey/train_series.dart';
import 'package:sfera/src/model/journey/train_series_speeds.dart';

final _log = Logger('GraduatedSpeedDataMapper');

/// Used to map data from SFERA to domain model [SpeedData].
class GraduatedSpeedDataMapper {
  GraduatedSpeedDataMapper._();

  /// Maps list of SFERA model [VelocityDto] to [SpeedData]
  static SpeedData? fromVelocities(Iterable<VelocityDto>? velocities) {
    if (velocities == null) return null;

    final graduatedSpeeds = <TrainSeriesSpeeds>[];

    void addSpeed(TrainSeries trainSeries, int? breakSeries, String speedString, bool reduced) {
      try {
        final speeds = TrainSeriesSpeeds.from(trainSeries, speedString, breakSeries: breakSeries, reduced: reduced);
        graduatedSpeeds.add(speeds);
      } catch (e) {
        _log.warning('Could not parse station speed with "$speedString"', e);
      }
    }

    for (final velocity in velocities) {
      if (velocity.speed != null) {
        addSpeed(velocity.trainSeries, velocity.brakeSeries, velocity.speed!, velocity.reduced);
      }
    }

    return SpeedData(speeds: graduatedSpeeds);
  }

  /// Maps SFERA model [GraduatedSpeedInfoDto] to [SpeedData]
  static SpeedData? fromGraduatedSpeedInfo(GraduatedSpeedInfoDto? graduatedSpeedInfo) {
    if (graduatedSpeedInfo == null) return null;

    final graduatedStationSpeeds = <TrainSeriesSpeeds>[];

    void addSpeed(TrainSeries trainSeries, String speedString, String? text) {
      try {
        final speeds = TrainSeriesSpeeds.from(trainSeries, speedString, text: text);
        graduatedStationSpeeds.add(speeds);
      } catch (e) {
        _log.warning('Could not parse graduated station speed with "$speedString"', e);
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

    return SpeedData(speeds: graduatedStationSpeeds);
  }
}
