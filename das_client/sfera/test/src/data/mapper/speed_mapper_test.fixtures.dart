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
    Signal(order: 950, kilometre: [], functions: [.entry]),
    ServicePoint(name: 'a', abbreviation: '', locationCode: '', order: 1000, kilometre: []),
    Signal(order: 1050, kilometre: [], functions: [.exit]),
    Signal(order: 2950, kilometre: [], functions: [.entry]),
    ServicePoint(name: 'b', abbreviation: '', locationCode: '', order: 3000, kilometre: []),
    Signal(order: 3050, kilometre: [], functions: [.exit]),
    Signal(order: 4950, kilometre: [], functions: [.entry]),
    ServicePoint(name: 'c', abbreviation: '', locationCode: '', order: 5000, kilometre: []),
    Signal(order: 5050, kilometre: [], functions: [.exit]),
  ];

  static List<JourneyPoint> get overTwoSegments => [
    Signal(order: 950, kilometre: [], functions: [.entry]),
    ServicePoint(name: 'a', abbreviation: '', locationCode: '', order: 1000, kilometre: []),
    Signal(order: 1050, kilometre: [], functions: [.exit]),
    Signal(order: 2950, kilometre: [], functions: [.entry]),
    ServicePoint(name: 'b', abbreviation: '', locationCode: '', order: 3000, kilometre: []),
    Signal(order: 3050, kilometre: [], functions: [.exit]),
    Signal(order: 100950, kilometre: [], functions: [.entry]),
    ServicePoint(name: 'c', abbreviation: '', locationCode: '', order: 101000, kilometre: []),
    Signal(order: 101050, kilometre: [], functions: [.exit]),
  ];

  static List<JourneyPoint> get overThreeSegments => [
    Signal(order: 950, kilometre: [], functions: [.entry]),
    ServicePoint(name: 'a', abbreviation: '', locationCode: '', order: 1000, kilometre: []),
    Signal(order: 1050, kilometre: [], functions: [.exit]),
    Signal(order: 100950, kilometre: [], functions: [.entry]),
    ServicePoint(name: 'b', abbreviation: '', locationCode: '', order: 101000, kilometre: []),
    Signal(order: 101050, kilometre: [], functions: [.exit]),
    Signal(order: 200950, kilometre: [], functions: [.entry]),
    ServicePoint(name: 'c', abbreviation: '', locationCode: '', order: 201000, kilometre: []),
    Signal(order: 201050, kilometre: [], functions: [.exit]),
  ];
}
