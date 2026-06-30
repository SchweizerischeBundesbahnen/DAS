import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ru_indications/component.dart';
import 'package:sfera/component.dart';

void main() {
  test(
    'combineFootNoteAndIndications_whenAllGiven_combinesOperationalIndicationRuIndicationFootNoteOnSameLocation',
    () {
      // GIVEN
      final footNoteToBeCombined = LineFootNote(
        order: 100,
        footNote: FootNote(text: 'Test A'),
        locationName: 'Location A',
      );
      final indicationsToBeCombined = [
        OperationalIndication(order: 100, texts: ['Test B']),
        RuIndication(order: 100, title: 'Title C', text: 'Test C'),
      ];
      final baseData = <BaseData>[
        footNoteToBeCombined,
        ...indicationsToBeCombined,
        LineFootNote(
          order: 300,
          footNote: FootNote(text: 'Test D'),
          locationName: 'Location D',
        ),
        OperationalIndication(order: 400, texts: ['Test E']),
        RuIndication(order: 500, title: 'Title F', text: 'Test F'),
      ];

      // WHEN
      final combinedDataList = baseData.combineFootNoteAndIndications();

      // THEN
      expect(combinedDataList, hasLength(4));
      final combinedData = combinedDataList.whereType<CombinedFootNoteAndIndications>().toList();
      expect(combinedData, hasLength(1));
      expect(combinedData[0].footNote, footNoteToBeCombined);
      expect(combinedData[0].indications, indicationsToBeCombined);
      expect(combinedDataList, isNot(contains(footNoteToBeCombined)));
      expect(combinedDataList, isNot(containsAll(indicationsToBeCombined)));
    },
  );

  test('combineFootNoteAndIndications_givenRuIndicationAndFootNote_combinesThemOnSameLocation', () {
    // GIVEN
    final footNoteToBeCombined = LineFootNote(
      order: 100,
      footNote: FootNote(text: 'Test A'),
      locationName: 'Location A',
    );
    final ruIndicationToBeCombined = RuIndication(order: 100, title: 'Title B', text: 'Test B');
    final baseData = <BaseData>[
      footNoteToBeCombined,
      ruIndicationToBeCombined,
      LineFootNote(
        order: 300,
        footNote: FootNote(text: 'Test C'),
        locationName: 'Location C',
      ),
      OperationalIndication(order: 400, texts: ['Test D']),
    ];

    // WHEN
    final combinedDataList = baseData.combineFootNoteAndIndications();

    // THEN
    expect(combinedDataList, hasLength(3));
    final combinedData = combinedDataList.whereType<CombinedFootNoteAndIndications>().toList();
    expect(combinedData, hasLength(1));
    expect(combinedData[0].footNote, footNoteToBeCombined);
    expect(combinedData[0].indications, [ruIndicationToBeCombined]);
    expect(combinedDataList, isNot(contains(footNoteToBeCombined)));
    expect(combinedDataList, isNot(contains(ruIndicationToBeCombined)));
  });

  test('combineFootNoteAndIndications_givenOperationalIndicationAndFootNote_combinesThemOnSameLocation', () {
    // GIVEN
    final footNoteToBeCombined = LineFootNote(
      order: 100,
      footNote: FootNote(text: 'Test A'),
      locationName: 'Location A',
    );
    final operationalIndicationToBeCombined = OperationalIndication(order: 100, texts: ['Test B']);
    final baseData = <BaseData>[
      footNoteToBeCombined,
      operationalIndicationToBeCombined,
      LineFootNote(
        order: 300,
        footNote: FootNote(text: 'Test C'),
        locationName: 'Location C',
      ),
      RuIndication(order: 500, title: 'Title E', text: 'Test E'),
    ];

    // WHEN
    final combinedDataList = baseData.combineFootNoteAndIndications();

    // THEN
    expect(combinedDataList, hasLength(3));
    final combinedData = combinedDataList.whereType<CombinedFootNoteAndIndications>().toList();
    expect(combinedData, hasLength(1));
    expect(combinedData[0].footNote, footNoteToBeCombined);
    expect(combinedData[0].indications, [operationalIndicationToBeCombined]);
    expect(combinedDataList, isNot(contains(footNoteToBeCombined)));
    expect(combinedDataList, isNot(contains(operationalIndicationToBeCombined)));
  });
}
