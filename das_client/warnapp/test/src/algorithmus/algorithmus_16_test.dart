import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:warnapp/src/algorithmus/algorithmus_16.dart';
import 'package:warnapp/src/algorithmus/algorithmus_16_properties.dart';

void main() {
  group('Algorithmus16 Tests', () {
    late Algorithmus16 algo16;

    setUp(() {
      algo16 = Algorithmus16(properties: Algorithmus16Properties.defaultProperties());
      initializeDateFormatting();
    });

    test('saveSoftSetInfo fahrtHysterese', () {
      algo16.saveSoftSetInfo(1, 0, 0, DateTime.fromMillisecondsSinceEpoch(60 * 60 * 1000));
      expect(algo16.softSetInfos, equals('1,02:00:00'));

      algo16.saveSoftSetInfo(1, 0, 0, DateTime.fromMillisecondsSinceEpoch(60 * 60 * 2000));
      expect(algo16.softSetInfos, equals('1,02:00:00;1,03:00:00'));
    });

    test('saveSoftSetInfo locationFahrtHysterese', () {
      algo16.saveSoftSetInfo(2, 1.5678, 2.9876, DateTime.fromMillisecondsSinceEpoch(60 * 60 * 1000));
      expect(algo16.softSetInfos, equals('2,02:00:00,1.5678,2.9876'));

      algo16.saveSoftSetInfo(2, 0, 0, DateTime.fromMillisecondsSinceEpoch(60 * 60 * 2000));
      expect(algo16.softSetInfos, equals('2,02:00:00,1.5678,2.9876;2,03:00:00,0.0,0.0'));
    });

    test('saveSoftSetInfo mixed', () {
      algo16.saveSoftSetInfo(1, 0, 0, DateTime.fromMillisecondsSinceEpoch(60 * 60 * 1000));
      algo16.saveSoftSetInfo(2, 1.5678, 2.9876, DateTime.fromMillisecondsSinceEpoch(60 * 60 * 2000));
      algo16.saveSoftSetInfo(1, 0, 0, DateTime.fromMillisecondsSinceEpoch(60 * 60 * 3000));
      algo16.saveSoftSetInfo(2, 0, 0, DateTime.fromMillisecondsSinceEpoch(60 * 60 * 4000));
      expect(algo16.softSetInfos, equals('1,02:00:00;2,03:00:00,1.5678,2.9876;1,04:00:00;2,05:00:00,0.0,0.0'));
    });

    test('updateWithAccelerationX does not fail', () {
      final abfahrt = algo16.updateWithAcceleration(
        0,
        0,
        0,
        0,
        0,
        0,
        false,
        0.1,
        0,
        0,
        0,
        0,
      );
      expect(abfahrt, isFalse);
    });
  });
}
