import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

import '../util/test_journey/test_journey_repository.dart';

void main() {
  const sferaStaticResourcesDirectoryPath = '../../sfera_mock/src/main/resources/static_sfera_resources';
  final testResourcesDir = Directory(sferaStaticResourcesDirectoryPath);
  final invalidJourney = ['T34'];

  test('whenSferaStaticResourcesDirPath_thenShouldFindDirectory', tags: 'sfera-mock-data-validator', () {
    expect(testResourcesDir.existsSync(), isTrue);
  });

  group('validatingJourneys', () {
    setUpAll(() {
      Logger.root.level = Level.WARNING;
      Logger.root.onRecord.listen((record) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      });
    });

    group('whenLoadingAllUniqueJourneysAndValidating_thenShouldAllBeValid', () {
      for (final testJourney in TestJourneyRepository.getAllUniqueJourneysByName()) {
        final journeyName = [testJourney.name, testJourney.eventName].nonNulls.join('-');
        test('whenParsingJourney_${journeyName}_thenShouldBeValid', tags: 'sfera-mock-data-validator', () {
          expect(testJourney.validate(), isTrue, reason: 'Expected $journeyName to be valid!');

          if (invalidJourney.any((it) => journeyName.contains(it))) {
            expect(testJourney.journey.valid, isFalse, reason: 'Expected $journeyName to be invalid!');
          } else {
            expect(testJourney.journey.valid, isTrue, reason: 'Expected $journeyName to be valid!');
          }
        });
      }
    });
  });
}
