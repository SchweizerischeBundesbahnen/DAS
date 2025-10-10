import 'package:sfera/component.dart';

class SpeedMapperTestFixtures {
  const SpeedMapperTestFixtures._();

  static List<JourneyPoint> get twoSignalJourney => [
    Signal(order: 0, kilometre: []),
    Signal(order: 100, kilometre: []),
  ];

  static List<JourneyPoint> get threeServicePointsWithSurroundingSignalsJourney =>
      ThreeServicePointsWithSurroundingSignalsJourneyFixture.data;
}

class ThreeServicePointsWithSurroundingSignalsJourneyFixture {
  const ThreeServicePointsWithSurroundingSignalsJourneyFixture._();

  static List<JourneyPoint> get data => [
    Signal(order: 950, kilometre: [], functions: [SignalFunction.entry]),
    ServicePoint(name: 'a', order: 1000, kilometre: []),
    Signal(order: 1050, kilometre: [], functions: [SignalFunction.exit]),
    Signal(order: 2950, kilometre: [], functions: [SignalFunction.entry]),
    ServicePoint(name: 'b', order: 3000, kilometre: []),
    Signal(order: 3050, kilometre: [], functions: [SignalFunction.exit]),
    Signal(order: 4950, kilometre: [], functions: [SignalFunction.entry]),
    ServicePoint(name: 'c', order: 5000, kilometre: []),
    Signal(order: 5050, kilometre: [], functions: [SignalFunction.exit]),
  ];

  static String get length => '5050';
}
