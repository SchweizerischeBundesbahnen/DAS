import 'package:das_client/model/journey/graduated_station_speeds.dart';
import 'package:das_client/model/journey/speed.dart';
import 'package:das_client/model/journey/train_series.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test with only incoming station speeds', () {
    // GIVEN WHEN
    final speed1 = GraduatedStationSpeeds.from([TrainSeries.R], '100');
    final speed2 = GraduatedStationSpeeds.from([TrainSeries.R], '100-90');
    final speed3 = GraduatedStationSpeeds.from([TrainSeries.R], '100-90-80');

    // THEN
    expect(speed1.incomingSpeeds, hasLength(1));
    checkSpeed(speed1.incomingSpeeds[0], 100);
    expect(speed1.outgoingSpeeds, isEmpty);

    expect(speed2.incomingSpeeds, hasLength(2));
    checkSpeed(speed2.incomingSpeeds[0], 100);
    checkSpeed(speed2.incomingSpeeds[1], 90);
    expect(speed2.outgoingSpeeds, isEmpty);

    expect(speed3.incomingSpeeds, hasLength(3));
    checkSpeed(speed3.incomingSpeeds[0], 100);
    checkSpeed(speed3.incomingSpeeds[1], 90);
    checkSpeed(speed3.incomingSpeeds[2], 80);
    expect(speed3.outgoingSpeeds, isEmpty);
  });
  test('test with incoming and outgoing station speeds', () {
    // GIVEN WHEN
    final speed1 = GraduatedStationSpeeds.from([TrainSeries.R], '100/70');
    final speed2 = GraduatedStationSpeeds.from([TrainSeries.R], '100-90/70');
    final speed3 = GraduatedStationSpeeds.from([TrainSeries.R], '100-90-80/70');
    final speed4 = GraduatedStationSpeeds.from([TrainSeries.R], '100/70-60');
    final speed5 = GraduatedStationSpeeds.from([TrainSeries.R], '100-90/70-60');
    final speed6 = GraduatedStationSpeeds.from([TrainSeries.R], '100-90-80/70-60');
    final speed7 = GraduatedStationSpeeds.from([TrainSeries.R], '100/70-60-50');
    final speed8 = GraduatedStationSpeeds.from([TrainSeries.R], '100-90/70-60-50');
    final speed9 = GraduatedStationSpeeds.from([TrainSeries.R], '100-90-80/70-60-50');

    // THEN
    expect(speed1.incomingSpeeds, hasLength(1));
    checkSpeed(speed1.incomingSpeeds[0], 100);
    expect(speed1.outgoingSpeeds, hasLength(1));
    checkSpeed(speed1.outgoingSpeeds[0], 70);

    expect(speed2.incomingSpeeds, hasLength(2));
    checkSpeed(speed2.incomingSpeeds[0], 100);
    checkSpeed(speed2.incomingSpeeds[1], 90);
    expect(speed2.outgoingSpeeds, hasLength(1));
    checkSpeed(speed2.outgoingSpeeds[0], 70);

    expect(speed3.incomingSpeeds, hasLength(3));
    checkSpeed(speed3.incomingSpeeds[0], 100);
    checkSpeed(speed3.incomingSpeeds[1], 90);
    checkSpeed(speed3.incomingSpeeds[2], 80);
    expect(speed3.outgoingSpeeds, hasLength(1));
    checkSpeed(speed3.outgoingSpeeds[0], 70);

    expect(speed4.incomingSpeeds, hasLength(1));
    checkSpeed(speed4.incomingSpeeds[0], 100);
    expect(speed4.outgoingSpeeds, hasLength(2));
    checkSpeed(speed4.outgoingSpeeds[0], 70);
    checkSpeed(speed4.outgoingSpeeds[1], 60);

    expect(speed5.incomingSpeeds, hasLength(2));
    checkSpeed(speed5.incomingSpeeds[0], 100);
    checkSpeed(speed5.incomingSpeeds[1], 90);
    expect(speed5.outgoingSpeeds, hasLength(2));
    checkSpeed(speed5.outgoingSpeeds[0], 70);
    checkSpeed(speed5.outgoingSpeeds[1], 60);

    expect(speed6.incomingSpeeds, hasLength(3));
    checkSpeed(speed6.incomingSpeeds[0], 100);
    checkSpeed(speed6.incomingSpeeds[1], 90);
    checkSpeed(speed6.incomingSpeeds[2], 80);
    expect(speed6.outgoingSpeeds, hasLength(2));
    checkSpeed(speed6.outgoingSpeeds[0], 70);
    checkSpeed(speed6.outgoingSpeeds[1], 60);

    expect(speed7.incomingSpeeds, hasLength(1));
    checkSpeed(speed7.incomingSpeeds[0], 100);
    expect(speed7.outgoingSpeeds, hasLength(3));
    checkSpeed(speed7.outgoingSpeeds[0], 70);
    checkSpeed(speed7.outgoingSpeeds[1], 60);
    checkSpeed(speed7.outgoingSpeeds[2], 50);

    expect(speed8.incomingSpeeds, hasLength(2));
    checkSpeed(speed8.incomingSpeeds[0], 100);
    checkSpeed(speed8.incomingSpeeds[1], 90);
    expect(speed8.outgoingSpeeds, hasLength(3));
    checkSpeed(speed8.outgoingSpeeds[0], 70);
    checkSpeed(speed8.outgoingSpeeds[1], 60);
    checkSpeed(speed8.outgoingSpeeds[2], 50);

    expect(speed9.incomingSpeeds, hasLength(3));
    checkSpeed(speed9.incomingSpeeds[0], 100);
    checkSpeed(speed9.incomingSpeeds[1], 90);
    checkSpeed(speed9.incomingSpeeds[2], 80);
    expect(speed9.outgoingSpeeds, hasLength(3));
    checkSpeed(speed9.outgoingSpeeds[0], 70);
    checkSpeed(speed9.outgoingSpeeds[1], 60);
    checkSpeed(speed9.outgoingSpeeds[2], 50);
  });
  test('test station speeds with circled or squared values', () {
    // GIVEN WHEN
    final speed1 = GraduatedStationSpeeds.from([TrainSeries.R], '100-{90}/70');
    final speed2 = GraduatedStationSpeeds.from([TrainSeries.R], '100/70-[60]');
    final speed3 = GraduatedStationSpeeds.from([TrainSeries.R], '[100]-90/{70}-[60]');

    // THEN
    expect(speed1.incomingSpeeds, hasLength(2));
    checkSpeed(speed1.incomingSpeeds[0], 100);
    checkSpeed(speed1.incomingSpeeds[1], 90, isCircled: true);
    expect(speed1.outgoingSpeeds, hasLength(1));
    checkSpeed(speed1.outgoingSpeeds[0], 70);

    expect(speed2.incomingSpeeds, hasLength(1));
    checkSpeed(speed2.incomingSpeeds[0], 100);
    expect(speed2.outgoingSpeeds, hasLength(2));
    checkSpeed(speed2.outgoingSpeeds[0], 70);
    checkSpeed(speed2.outgoingSpeeds[1], 60, isSquared: true);

    expect(speed3.incomingSpeeds, hasLength(2));
    checkSpeed(speed3.incomingSpeeds[0], 100, isSquared: true);
    checkSpeed(speed3.incomingSpeeds[1], 90);
    expect(speed3.outgoingSpeeds, hasLength(2));
    checkSpeed(speed3.outgoingSpeeds[0], 70, isCircled: true);
    checkSpeed(speed3.outgoingSpeeds[1], 60, isSquared: true);
  });

  test('test invalid speed format', () {
    expect(() => GraduatedStationSpeeds.from([TrainSeries.R], 'ABC'), throwsArgumentError);
    expect(() => GraduatedStationSpeeds.from([TrainSeries.R], '1A-{90}/70'), throwsArgumentError);
    expect(() => GraduatedStationSpeeds.from([TrainSeries.R], '100--20'), throwsArgumentError);
    expect(() => GraduatedStationSpeeds.from([TrainSeries.R], '100-{{90}'), throwsArgumentError);
    expect(() => GraduatedStationSpeeds.from([TrainSeries.R], '100-{90}//70'), throwsArgumentError);
  });
}

void checkSpeed(Speed speed, int speedValue, {bool isCircled = false, bool isSquared = false}) {
  expect(speed.speed, speedValue);
  expect(speed.isCircled, isCircled);
  expect(speed.isSquared, isSquared);
}
