import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../util/test_journey_loader.dart';

void main() {
  const sferaStaticResourcesDirectoryPath = '../../sfera_mock/src/main/resources/static_sfera_resources';
  final testResourcesDir = Directory(sferaStaticResourcesDirectoryPath);

  test('whenSferaStaticResourcesDirPath_thenShouldFindDirectory', tags: 'sfera-mock-data-validator', () {
    expect(testResourcesDir.existsSync(), isTrue);
  });

  group('whenLoadingAllJourneysFromSferaTestResourcesDir_thenShould', () {
    for (final testJourney in TestJourneyLoader.fromStaticSferaResources()) {
      final journeyName = [testJourney.name, testJourney.eventName].join('-');
      test('whenParsingJourney_${journeyName}_thenShouldBeValid', tags: 'sfera-mock-data-validator', () {
        expect(testJourney.journey.valid, isTrue);
      });
    }
  });

  group('whenLoadingAllJourneysFromClientTestResourcesDir_thenShouldAllBeValid', () {
    for (final testJourney in TestJourneyLoader.fromClientTestResources()) {
      final journeyName = [testJourney.name, testJourney.eventName].nonNulls.join('-');
      test('whenParsingJourney_${journeyName}_thenShouldBeValid', tags: 'sfera-mock-data-validator', () {
        expect(testJourney.journey.valid, isTrue);
      });
    }
  });
}
