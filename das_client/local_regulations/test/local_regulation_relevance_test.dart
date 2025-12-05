import 'package:flutter_test/flutter_test.dart';
import 'package:local_regulations/src/local_regulation_relevance.dart';

void main() {
  test('from_whenStartsWithAbbreviation_thenReturnRelevance', () {
    _checkAbbreviationAtStart('ZR', .trainJourneysAndShuntingManoeuvres);
    _checkAbbreviationAtStart('Z', .trainJourneys);
    _checkAbbreviationAtStart('R', .shuntingManoeuvres);
    _checkAbbreviationAtStart('GV', .crossBorderTraffic);
    _checkAbbreviationAtStart('Fdl', .trafficControllers);
  });

  test('from_whenUnknownAbbreviation_thenReturnNull', () {
    _checkAbbreviationAtStart('HR', null);
    _checkAbbreviationAtStart('SAP', null);
  });

  test('from_whenEmpty_thenReturnNull', () {
    // ACT & EXPECT
    final result = LocalRegulationRelevance.from('');
    expect(result, isNull);
  });

  test('from_whenAbbreviationNotAtStart_thenReturnNull', () {
    _checkAbbreviationNotAtStart('ZR');
    _checkAbbreviationNotAtStart('Z');
    _checkAbbreviationNotAtStart('R');
    _checkAbbreviationNotAtStart('GV');
    _checkAbbreviationNotAtStart('Fdl');
  });
}

void _checkAbbreviationAtStart(String abbreviation, LocalRegulationRelevance? expected) {
  // ARRANGE
  final text = '$abbreviation Test Text';

  // ACT & EXPECT
  final result = LocalRegulationRelevance.from(text);
  expect(result, expected);
}

void _checkAbbreviationNotAtStart(String abbreviation) {
  // ARRANGE
  final abbreviationBetween = 'Test $abbreviation Text';
  final abbreviationAtEnd = 'Test Text $abbreviation';

  // ACT & EXPECT
  expect(LocalRegulationRelevance.from(abbreviationBetween), isNull);
  expect(LocalRegulationRelevance.from(abbreviationAtEnd), isNull);
}
