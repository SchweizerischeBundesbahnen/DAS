import 'package:app/provider/timed_route_provider_impl.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('TimedRouteProviderImpl', () {
    late TimedRouteProviderImpl provider;

    setUp(() {
      provider = TimedRouteProviderImpl();
    });

    group('isInTimedAdvancementRoute', () {
      test('isInTimedAdvancementRoute_whenUpdatedPositionIsNull_thenReturnsFalse', () {
        final result = provider.isInTimedAdvancementRoute(null, []);
        expect(result, isFalse);
      });

      test('isInTimedAdvancementRoute_whenUpdatedPositionIsNotServicePoint_thenReturnsFalse', () {
        final signal = Signal(order: 1, kilometre: [0.0]);
        final result = provider.isInTimedAdvancementRoute(signal, []);
        expect(result, isFalse);
      });

      test(
        'isInTimedAdvancementRoute_whenLocationCodeNotInTimedRoute_thenReturnsFalse',
        () {
          final servicePoint = ServicePoint(
            name: 'Unknown Station',
            abbreviation: 'UNK',
            locationCode: 'CH00000',
            order: 1,
            kilometre: [0.0],
          );

          final result = provider.isInTimedAdvancementRoute(servicePoint, []);
          expect(result, isFalse);
        },
      );

      test(
        'isInTimedAdvancementRoute_whenNoNextServicePointExists_thenReturnsFalse',
        () {
          final servicePoint = ServicePoint(
            name: 'Iselle',
            abbreviation: 'ISL',
            locationCode: 'CH01952',
            order: 1,
            kilometre: [0.0],
          );

          final result = provider.isInTimedAdvancementRoute(
            servicePoint,
            [servicePoint],
          );
          expect(result, isFalse);
        },
      );

      test(
        'isInTimedAdvancementRoute_whenNextPointHasNoPlannedArrivalTime_thenReturnsFalse',
        () {
          final currentPoint = ServicePoint(
            name: 'Iselle',
            abbreviation: 'ISL',
            locationCode: 'CH01952',
            order: 1,
            kilometre: [0.0],
          );
          final nextPoint = ServicePoint(
            name: 'Varzo',
            abbreviation: 'VRZ',
            locationCode: 'CH01951',
            order: 2,
            kilometre: [5.0],
            arrivalDepartureTime: const ArrivalDepartureTime(),
          );

          final result = provider.isInTimedAdvancementRoute(
            currentPoint,
            [currentPoint, nextPoint],
          );
          expect(result, isFalse);
        },
      );

      test(
        'isInTimedAdvancementRoute_whenNextPointHasPlannedArrivalTime_thenReturnsTrue',
        () {
          final currentPoint = ServicePoint(
            name: 'Iselle',
            abbreviation: 'ISL',
            locationCode: 'CH01952',
            order: 1,
            kilometre: [0.0],
          );
          final nextPoint = ServicePoint(
            name: 'Varzo',
            abbreviation: 'VRZ',
            locationCode: 'CH01951',
            order: 2,
            kilometre: [5.0],
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: DateTime.now().add(const Duration(minutes: 30)),
            ),
          );

          final result = provider.isInTimedAdvancementRoute(
            currentPoint,
            [currentPoint, nextPoint],
          );
          expect(result, isTrue);
        },
      );

      test(
        'isInTimedAdvancementRoute_whenSkippingToNextPointInTimedRoute_thenReturnsTrue',
        () {
          final point1 = ServicePoint(
            name: 'Iselle',
            abbreviation: 'ISL',
            locationCode: 'CH01952',
            order: 1,
            kilometre: [0.0],
          );
          final point2 = ServicePoint(
            name: 'Varzo',
            abbreviation: 'VRZ',
            locationCode: 'CH01951',
            order: 2,
            kilometre: [5.0],
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: DateTime.now().add(const Duration(hours: 1)),
            ),
          );
          final point3 = ServicePoint(
            name: 'Preglia',
            abbreviation: 'PRG',
            locationCode: 'CH01950',
            order: 3,
            kilometre: [10.0],
          );
          final point4 = ServicePoint(
            name: 'Other',
            abbreviation: 'OTH',
            locationCode: 'UNKNOWN',
            order: 4,
            kilometre: [15.0],
          );

          final result = provider.isInTimedAdvancementRoute(
            point1,
            [point1, point2, point3, point4],
          );
          expect(result, isTrue);
        },
      );

      test('isInTimedAdvancementRoute_whenSecondTimedRoute_thenReturnsTrue', () {
        final currentPoint = ServicePoint(
          name: 'Pino Confine',
          abbreviation: 'PIN',
          locationCode: 'CH15419',
          order: 1,
          kilometre: [0.0],
        );
        final nextPoint = ServicePoint(
          name: 'PINT',
          abbreviation: 'PNT',
          locationCode: 'CH05862',
          order: 2,
          kilometre: [5.0],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: DateTime.now().add(const Duration(minutes: 15)),
          ),
        );

        final result = provider.isInTimedAdvancementRoute(
          currentPoint,
          [currentPoint, nextPoint],
        );
        expect(result, isTrue);
      });
    });

    group('calculateNextTimedServicePoint', () {
      test('calculateNextTimedServicePoint_whenUpdatedPositionIsNotServicePoint_thenReturnsNull', () {
        final signal = Signal(order: 1, kilometre: [0.0]);
        final result = provider.calculateNextTimedServicePoint(signal, []);
        expect(result, isNull);
      });

      test(
        'calculateNextTimedServicePoint_whenLocationCodeNotInTimedRoute_thenReturnsNull',
        () {
          final servicePoint = ServicePoint(
            name: 'Unknown Station',
            abbreviation: 'UNK',
            locationCode: 'CH00000',
            order: 1,
            kilometre: [0.0],
          );

          final result = provider.calculateNextTimedServicePoint(servicePoint, []);
          expect(result, isNull);
        },
      );

      test('calculateNextTimedServicePoint_whenNoNextServicePointExists_thenReturnsNull', () {
        final servicePoint = ServicePoint(
          name: 'Iselle',
          abbreviation: 'ISL',
          locationCode: 'CH01952',
          order: 1,
          kilometre: [0.0],
        );

        final result = provider.calculateNextTimedServicePoint(
          servicePoint,
          [servicePoint],
        );
        expect(result, isNull);
      });

      test(
        'calculateNextTimedServicePoint_whenCalculating_thenReturnsTimeDifferenceAndNextPoint',
        () {
          final plannedArrivalTime = DateTime(2024, 7, 6, 10, 30, 0);
          final currentPoint = ServicePoint(
            name: 'Iselle',
            abbreviation: 'ISL',
            locationCode: 'CH01952',
            order: 1,
            kilometre: [0.0],
          );
          final nextPoint = ServicePoint(
            name: 'Varzo',
            abbreviation: 'VRZ',
            locationCode: 'CH01951',
            order: 2,
            kilometre: [5.0],
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: plannedArrivalTime,
            ),
          );

          withClock(Clock.fixed(DateTime(2024, 7, 6, 10, 0, 0)), () {
            final result = provider.calculateNextTimedServicePoint(
              currentPoint,
              [currentPoint, nextPoint],
            );

            expect(result, isNotNull);
            expect(result?.$2, equals(nextPoint));
            // 30 minutes = 1800 seconds
            expect(result?.$1.inSeconds, equals(30 * 60));
          });
        },
      );

      test(
        'calculateNextTimedServicePoint_whenNextPointAlreadyReached_thenReturnsNegativeTime',
        () {
          final plannedArrivalTime = DateTime(2024, 7, 6, 10, 0, 0);
          final currentPoint = ServicePoint(
            name: 'Iselle',
            abbreviation: 'ISL',
            locationCode: 'CH01952',
            order: 1,
            kilometre: [0.0],
          );
          final nextPoint = ServicePoint(
            name: 'Varzo',
            abbreviation: 'VRZ',
            locationCode: 'CH01951',
            order: 2,
            kilometre: [5.0],
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: plannedArrivalTime,
            ),
          );

          withClock(Clock.fixed(DateTime(2024, 7, 6, 10, 30, 0)), () {
            final result = provider.calculateNextTimedServicePoint(
              currentPoint,
              [currentPoint, nextPoint],
            );

            expect(result, isNotNull);
            expect(result?.$2, equals(nextPoint));
            // Time is in the past (30 minutes)
            expect(result?.$1.inSeconds, equals(-30 * 60));
          });
        },
      );

      test(
        'calculateNextTimedServicePoint_whenCurrentTimeEqualsPlannedArrivalTime_thenReturnsZeroTime',
        () {
          final now = DateTime(2024, 7, 6, 10, 30, 0);
          final currentPoint = ServicePoint(
            name: 'Iselle',
            abbreviation: 'ISL',
            locationCode: 'CH01952',
            order: 1,
            kilometre: [0.0],
          );
          final nextPoint = ServicePoint(
            name: 'Varzo',
            abbreviation: 'VRZ',
            locationCode: 'CH01951',
            order: 2,
            kilometre: [5.0],
            arrivalDepartureTime: ArrivalDepartureTime(plannedArrivalTime: now),
          );

          withClock(Clock.fixed(now), () {
            final result = provider.calculateNextTimedServicePoint(
              currentPoint,
              [currentPoint, nextPoint],
            );

            expect(result, isNotNull);
            expect(result?.$2, equals(nextPoint));
            expect(result?.$1.inSeconds, equals(0));
          });
        },
      );

      test(
        'calculateNextTimedServicePoint_whenSkippingIntermediatePointsWithoutPlannedArrivalTime_thenSkips',
        () {
          final plannedArrivalTime = DateTime(2024, 7, 6, 10, 45, 0);
          final point1 = ServicePoint(
            name: 'Iselle',
            abbreviation: 'ISL',
            locationCode: 'CH01952',
            order: 1,
            kilometre: [0.0],
          );
          final point2 = ServicePoint(
            name: 'Varzo',
            abbreviation: 'VRZ',
            locationCode: 'CH01951',
            order: 2,
            kilometre: [5.0],
          );
          final point3 = ServicePoint(
            name: 'Preglia',
            abbreviation: 'PRG',
            locationCode: 'CH01950',
            order: 3,
            kilometre: [10.0],
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: plannedArrivalTime,
            ),
          );

          withClock(Clock.fixed(DateTime(2024, 7, 6, 10, 0, 0)), () {
            final result = provider.calculateNextTimedServicePoint(
              point1,
              [point1, point2, point3],
            );

            expect(result, isNotNull);
            expect(result?.$2, equals(point3));
            // 45 minutes = 45 * 60
            expect(result?.$1.inSeconds, equals(45 * 60));
          });
        },
      );

      test(
        'calculateNextTimedServicePoint_whenSecondTimedRoute_thenReturnsCorrectTime',
        () {
          final plannedArrivalTime = DateTime(2024, 7, 6, 9, 20, 0);
          final point1 = ServicePoint(
            name: 'Pino Confine',
            abbreviation: 'PIN',
            locationCode: 'CH15419',
            order: 1,
            kilometre: [0.0],
          );
          final point2 = ServicePoint(
            name: 'PINT',
            abbreviation: 'PNT',
            locationCode: 'CH05862',
            order: 2,
            kilometre: [5.0],
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: plannedArrivalTime,
            ),
          );

          withClock(Clock.fixed(DateTime(2024, 7, 6, 9, 0, 0)), () {
            final result = provider.calculateNextTimedServicePoint(
              point1,
              [point1, point2],
            );

            expect(result, isNotNull);
            expect(result?.$2, equals(point2));
            // 20 minutes = 20 * 60 milliseconds
            expect(result?.$1.inSeconds, equals(20 * 60));
          });
        },
      );
    });
  });
}
