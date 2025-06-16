import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/speed.dart';
import 'package:sfera/src/model/journey/speed_data.dart';
import 'package:sfera/src/model/journey/speeds.dart';
import 'package:sfera/src/model/journey/train_series.dart';

void main() {
  test('test with only incoming station speeds', () {
    // GIVEN WHEN
    final speed1 = Speeds.from(TrainSeries.R, '100');
    final speed2 = Speeds.from(TrainSeries.R, '100-90');
    final speed3 = Speeds.from(TrainSeries.R, '100-90-80');

    // THEN
    expect(speed1.incomingSpeeds, hasLength(1));
    checkSpeed(speed1.incomingSpeeds[0], '100');
    expect(speed1.outgoingSpeeds, isEmpty);

    expect(speed2.incomingSpeeds, hasLength(2));
    checkSpeed(speed2.incomingSpeeds[0], '100');
    checkSpeed(speed2.incomingSpeeds[1], '90');
    expect(speed2.outgoingSpeeds, isEmpty);

    expect(speed3.incomingSpeeds, hasLength(3));
    checkSpeed(speed3.incomingSpeeds[0], '100');
    checkSpeed(speed3.incomingSpeeds[1], '90');
    checkSpeed(speed3.incomingSpeeds[2], '80');
    expect(speed3.outgoingSpeeds, isEmpty);
  });

  test('test with XX speeds', () {
    // GIVEN WHEN
    final speed1 = Speeds.from(TrainSeries.R, 'XX');

    // THEN
    expect(speed1.incomingSpeeds, hasLength(1));
    checkSpeed(speed1.incomingSpeeds[0], 'XX');
    expect(speed1.outgoingSpeeds, isEmpty);
  });

  test('test with incoming and outgoing station speeds', () {
    // GIVEN WHEN
    final speed1 = Speeds.from(TrainSeries.R, '100/70');
    final speed2 = Speeds.from(TrainSeries.R, '100-90/70');
    final speed3 = Speeds.from(TrainSeries.R, '100-90-80/70');
    final speed4 = Speeds.from(TrainSeries.R, '100/70-60');
    final speed5 = Speeds.from(TrainSeries.R, '100-90/70-60');
    final speed6 = Speeds.from(TrainSeries.R, '100-90-80/70-60');
    final speed7 = Speeds.from(TrainSeries.R, '100/70-60-50');
    final speed8 = Speeds.from(TrainSeries.R, '100-90/70-60-50');
    final speed9 = Speeds.from(TrainSeries.R, '100-90-80/70-60-50');

    // THEN
    expect(speed1.incomingSpeeds, hasLength(1));
    checkSpeed(speed1.incomingSpeeds[0], '100');
    expect(speed1.outgoingSpeeds, hasLength(1));
    checkSpeed(speed1.outgoingSpeeds[0], '70');

    expect(speed2.incomingSpeeds, hasLength(2));
    checkSpeed(speed2.incomingSpeeds[0], '100');
    checkSpeed(speed2.incomingSpeeds[1], '90');
    expect(speed2.outgoingSpeeds, hasLength(1));
    checkSpeed(speed2.outgoingSpeeds[0], '70');

    expect(speed3.incomingSpeeds, hasLength(3));
    checkSpeed(speed3.incomingSpeeds[0], '100');
    checkSpeed(speed3.incomingSpeeds[1], '90');
    checkSpeed(speed3.incomingSpeeds[2], '80');
    expect(speed3.outgoingSpeeds, hasLength(1));
    checkSpeed(speed3.outgoingSpeeds[0], '70');

    expect(speed4.incomingSpeeds, hasLength(1));
    checkSpeed(speed4.incomingSpeeds[0], '100');
    expect(speed4.outgoingSpeeds, hasLength(2));
    checkSpeed(speed4.outgoingSpeeds[0], '70');
    checkSpeed(speed4.outgoingSpeeds[1], '60');

    expect(speed5.incomingSpeeds, hasLength(2));
    checkSpeed(speed5.incomingSpeeds[0], '100');
    checkSpeed(speed5.incomingSpeeds[1], '90');
    expect(speed5.outgoingSpeeds, hasLength(2));
    checkSpeed(speed5.outgoingSpeeds[0], '70');
    checkSpeed(speed5.outgoingSpeeds[1], '60');

    expect(speed6.incomingSpeeds, hasLength(3));
    checkSpeed(speed6.incomingSpeeds[0], '100');
    checkSpeed(speed6.incomingSpeeds[1], '90');
    checkSpeed(speed6.incomingSpeeds[2], '80');
    expect(speed6.outgoingSpeeds, hasLength(2));
    checkSpeed(speed6.outgoingSpeeds[0], '70');
    checkSpeed(speed6.outgoingSpeeds[1], '60');

    expect(speed7.incomingSpeeds, hasLength(1));
    checkSpeed(speed7.incomingSpeeds[0], '100');
    expect(speed7.outgoingSpeeds, hasLength(3));
    checkSpeed(speed7.outgoingSpeeds[0], '70');
    checkSpeed(speed7.outgoingSpeeds[1], '60');
    checkSpeed(speed7.outgoingSpeeds[2], '50');

    expect(speed8.incomingSpeeds, hasLength(2));
    checkSpeed(speed8.incomingSpeeds[0], '100');
    checkSpeed(speed8.incomingSpeeds[1], '90');
    expect(speed8.outgoingSpeeds, hasLength(3));
    checkSpeed(speed8.outgoingSpeeds[0], '70');
    checkSpeed(speed8.outgoingSpeeds[1], '60');
    checkSpeed(speed8.outgoingSpeeds[2], '50');

    expect(speed9.incomingSpeeds, hasLength(3));
    checkSpeed(speed9.incomingSpeeds[0], '100');
    checkSpeed(speed9.incomingSpeeds[1], '90');
    checkSpeed(speed9.incomingSpeeds[2], '80');
    expect(speed9.outgoingSpeeds, hasLength(3));
    checkSpeed(speed9.outgoingSpeeds[0], '70');
    checkSpeed(speed9.outgoingSpeeds[1], '60');
    checkSpeed(speed9.outgoingSpeeds[2], '50');
  });
  test('test station speeds with circled or squared values', () {
    // GIVEN WHEN
    final speed1 = Speeds.from(TrainSeries.R, '100-{90}/70');
    final speed2 = Speeds.from(TrainSeries.R, '100/70-[60]');
    final speed3 = Speeds.from(TrainSeries.R, '[100]-90/{70}-[60]');

    // THEN
    expect(speed1.incomingSpeeds, hasLength(2));
    checkSpeed(speed1.incomingSpeeds[0], '100');
    checkSpeed(speed1.incomingSpeeds[1], '90', isCircled: true);
    expect(speed1.outgoingSpeeds, hasLength(1));
    checkSpeed(speed1.outgoingSpeeds[0], '70');

    expect(speed2.incomingSpeeds, hasLength(1));
    checkSpeed(speed2.incomingSpeeds[0], '100');
    expect(speed2.outgoingSpeeds, hasLength(2));
    checkSpeed(speed2.outgoingSpeeds[0], '70');
    checkSpeed(speed2.outgoingSpeeds[1], '60', isSquared: true);

    expect(speed3.incomingSpeeds, hasLength(2));
    checkSpeed(speed3.incomingSpeeds[0], '100', isSquared: true);
    checkSpeed(speed3.incomingSpeeds[1], '90');
    expect(speed3.outgoingSpeeds, hasLength(2));
    checkSpeed(speed3.outgoingSpeeds[0], '70', isCircled: true);
    checkSpeed(speed3.outgoingSpeeds[1], '60', isSquared: true);
  });

  test('test invalid speed format', () {
    expect(() => Speeds.from(TrainSeries.R, 'ABC'), throwsArgumentError);
    expect(() => Speeds.from(TrainSeries.R, '1A-{90}/70'), throwsArgumentError);
    expect(() => Speeds.from(TrainSeries.R, '100--20'), throwsArgumentError);
    expect(() => Speeds.from(TrainSeries.R, '100-{{90}'), throwsArgumentError);
    expect(() => Speeds.from(TrainSeries.R, '100-{90}//70'), throwsArgumentError);
  });

  test('Test resolved speed no velocities', () {
    final speedData = SpeedData();

    expect(speedData.speedsFor(TrainSeries.R, 150), isNull);
    expect(speedData.speedsFor(TrainSeries.A, 150), isNull);
  });

  test('Test resolved speed exact match', () {
    final speedData = SpeedData(
      speeds: [
        Speeds(trainSeries: TrainSeries.R, breakSeries: 100, incomingSpeeds: [Speed.from('100')], reduced: false),
        Speeds(trainSeries: TrainSeries.R, breakSeries: 150, incomingSpeeds: [Speed.from('150')], reduced: false),
        Speeds(trainSeries: TrainSeries.A, breakSeries: 100, incomingSpeeds: [Speed.from('200')], reduced: false),
        Speeds(trainSeries: TrainSeries.A, breakSeries: 150, incomingSpeeds: [Speed.from('250')], reduced: false),
      ],
    );

    expect(speedData.speedsFor(TrainSeries.R, 100)!.incomingSpeeds[0].speed, '100');
    expect(speedData.speedsFor(TrainSeries.R, 150)!.incomingSpeeds[0].speed, '150');
    expect(speedData.speedsFor(TrainSeries.A, 100)!.incomingSpeeds[0].speed, '200');
    expect(speedData.speedsFor(TrainSeries.A, 150)!.incomingSpeeds[0].speed, '250');
  });

  test('Test resolved speed default break series', () {
    final speedData = SpeedData(
      speeds: [
        Speeds(trainSeries: TrainSeries.R, breakSeries: 100, incomingSpeeds: [Speed.from('100')], reduced: false),
        Speeds(trainSeries: TrainSeries.R, incomingSpeeds: [Speed.from('150')], reduced: false),
        Speeds(trainSeries: TrainSeries.A, incomingSpeeds: [Speed.from('200')], reduced: false),
        Speeds(trainSeries: TrainSeries.A, breakSeries: 150, incomingSpeeds: [Speed.from('250')], reduced: false),
      ],
    );

    expect(speedData.speedsFor(TrainSeries.R, 100)!.incomingSpeeds[0].speed, '100');
    expect(speedData.speedsFor(TrainSeries.R, 150)!.incomingSpeeds[0].speed, '150');
    expect(speedData.speedsFor(TrainSeries.R, 50)!.incomingSpeeds[0].speed, '150');
    expect(speedData.speedsFor(TrainSeries.A, 100)!.incomingSpeeds[0].speed, '200');
    expect(speedData.speedsFor(TrainSeries.A, 150)!.incomingSpeeds[0].speed, '250');
    expect(speedData.speedsFor(TrainSeries.A, 80)!.incomingSpeeds[0].speed, '200');
  });
}

void checkSpeed(Speed speed, String speedValue, {bool isCircled = false, bool isSquared = false}) {
  expect(speed.speed, speedValue);
  expect(speed.isCircled, isCircled);
  expect(speed.isSquared, isSquared);
}
