import 'package:das_client/model/journey/signal.dart';
import 'package:das_client/model/journey/speed_data.dart';
import 'package:das_client/model/journey/train_series.dart';
import 'package:das_client/model/journey/velocity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test resolved speed no velocities', () {
    final speedData = SpeedData();

    expect(speedData.resolvedSpeed(TrainSeries.R, 150), isNull);
    expect(speedData.resolvedSpeed(TrainSeries.A, 150), isNull);
  });

  test('Test resolved speed exact match', () {
    final speedData = SpeedData(velocities: [
      Velocity(trainSeries: TrainSeries.R, breakSeries: 100, speed: '100', reduced: false),
      Velocity(trainSeries: TrainSeries.R, breakSeries: 150, speed: '150', reduced: false),
      Velocity(trainSeries: TrainSeries.A, breakSeries: 100, speed: '200', reduced: false),
      Velocity(trainSeries: TrainSeries.A, breakSeries: 150, speed: '250', reduced: false),
    ]);

    expect(speedData.resolvedSpeed(TrainSeries.R, 100), '100');
    expect(speedData.resolvedSpeed(TrainSeries.R, 150), '150');
    expect(speedData.resolvedSpeed(TrainSeries.A, 100), '200');
    expect(speedData.resolvedSpeed(TrainSeries.A, 150), '250');
  });

  test('Test resolved speed default break series', () {
    final speedData = SpeedData(velocities: [
      Velocity(trainSeries: TrainSeries.R, breakSeries: 100, speed: '100', reduced: false),
      Velocity(trainSeries: TrainSeries.R, speed: '150', reduced: false),
      Velocity(trainSeries: TrainSeries.A, speed: '200', reduced: false),
      Velocity(trainSeries: TrainSeries.A, breakSeries: 150, speed: '250', reduced: false),
    ]);

    expect(speedData.resolvedSpeed(TrainSeries.R, 100), '100');
    expect(speedData.resolvedSpeed(TrainSeries.R, 150), '150');
    expect(speedData.resolvedSpeed(TrainSeries.R, 50), '150');
    expect(speedData.resolvedSpeed(TrainSeries.A, 100), '200');
    expect(speedData.resolvedSpeed(TrainSeries.A, 150), '250');
    expect(speedData.resolvedSpeed(TrainSeries.A, 80), '200');
  });
}
