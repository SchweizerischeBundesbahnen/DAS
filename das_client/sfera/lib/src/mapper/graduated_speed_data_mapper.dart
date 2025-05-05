import 'package:app/model/journey/speed_data.dart';
import 'package:app/model/journey/speeds.dart';
import 'package:app/model/journey/train_series.dart';
import 'package:sfera/src/model/graduated_speed_info.dart';
import 'package:sfera/src/model/velocity.dart';
import 'package:fimber/fimber.dart';

/// Used to map data from SFERA to domain model [SpeedData].
class GraduatedSpeedDataMapper {
  GraduatedSpeedDataMapper._();

  /// Maps list of SFERA model [Velocity] to [SpeedData]
  static SpeedData? fromVelocities(Iterable<Velocity>? velocities) {
    if (velocities == null) return null;

    final graduatedSpeeds = <Speeds>[];

    void addSpeed(TrainSeries trainSeries, int? breakSeries, String speedString, bool reduced) {
      try {
        final speeds = Speeds.from(trainSeries, speedString, breakSeries: breakSeries, reduced: reduced);
        graduatedSpeeds.add(speeds);
      } catch (e) {
        Fimber.w('Could not parse station speed with "$speedString"', ex: e);
      }
    }

    for (final velocity in velocities) {
      if (velocity.speed != null) {
        addSpeed(velocity.trainSeries, velocity.brakeSeries, velocity.speed!, velocity.reduced);
      }
    }

    return SpeedData(speeds: graduatedSpeeds);
  }

  /// Maps SFERA model [GraduatedSpeedInfo] to [SpeedData]
  static SpeedData? fromGraduatedSpeedInfo(GraduatedSpeedInfo? graduatedSpeedInfo) {
    if (graduatedSpeedInfo == null) return null;

    final graduatedStationSpeeds = <Speeds>[];

    void addSpeed(TrainSeries trainSeries, String speedString, String? text) {
      try {
        final speeds = Speeds.from(trainSeries, speedString, text: text);
        graduatedStationSpeeds.add(speeds);
      } catch (e) {
        Fimber.w('Could not parse graduated station speed with "$speedString"', ex: e);
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
