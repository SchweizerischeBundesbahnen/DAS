import 'package:sfera/component.dart';

class SpeedMapperTestFixtures {
  const SpeedMapperTestFixtures._();

  static List<JourneyPoint> get twoSignalJourney => [
    Signal(order: 0, kilometre: []),
    Signal(order: 100, kilometre: []),
  ];
}

class ThreeServicePointsWithSurroundingSignalsJourneyFixture {
  const ThreeServicePointsWithSurroundingSignalsJourneyFixture._();

  static List<JourneyPoint> get overOneSegment => [
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

  static List<JourneyPoint> get overTwoSegments => [
    Signal(order: 950, kilometre: [], functions: [SignalFunction.entry]),
    ServicePoint(name: 'a', order: 1000, kilometre: []),
    Signal(order: 1050, kilometre: [], functions: [SignalFunction.exit]),
    Signal(order: 2950, kilometre: [], functions: [SignalFunction.entry]),
    ServicePoint(name: 'b', order: 3000, kilometre: []),
    Signal(order: 3050, kilometre: [], functions: [SignalFunction.exit]),
    Signal(order: 100950, kilometre: [], functions: [SignalFunction.entry]),
    ServicePoint(name: 'c', order: 101000, kilometre: []),
    Signal(order: 101050, kilometre: [], functions: [SignalFunction.exit]),
  ];

  static List<JourneyPoint> get overThreeSegments => [
    Signal(order: 950, kilometre: [], functions: [SignalFunction.entry]),
    ServicePoint(name: 'a', order: 1000, kilometre: []),
    Signal(order: 1050, kilometre: [], functions: [SignalFunction.exit]),
    Signal(order: 100950, kilometre: [], functions: [SignalFunction.entry]),
    ServicePoint(name: 'b', order: 101000, kilometre: []),
    Signal(order: 101050, kilometre: [], functions: [SignalFunction.exit]),
    Signal(order: 200950, kilometre: [], functions: [SignalFunction.entry]),
    ServicePoint(name: 'c', order: 201000, kilometre: []),
    Signal(order: 201050, kilometre: [], functions: [SignalFunction.exit]),
  ];
}
