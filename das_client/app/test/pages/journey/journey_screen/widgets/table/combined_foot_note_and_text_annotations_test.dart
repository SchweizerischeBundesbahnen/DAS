import 'package:app/pages/journey/journey_screen/view_model/personal_note_annotation.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/combined_foot_note_and_text_annotations.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ru_indications/component.dart';
import 'package:sfera/component.dart';

void main() {
  test(
    'combineFootNoteAndTextAnnotations_whenAllGiven_combinesTextAnnotationsAndFootNoteOnSameLocation',
    () {
      // GIVEN
      final footNoteToBeCombined = LineFootNote(
        order: 100,
        footNote: FootNote(text: 'Test A'),
        locationName: 'Location A',
      );
      final textAnnotationsToBeCombined = [
        OperationalIndication(order: 100, texts: ['Test B']),
        RuIndication(order: 100, title: 'Title C', text: 'Test C'),
        PersonalNoteAnnotation(order: 100, text: 'Test D'),
      ];
      final baseData = <BaseData>[
        footNoteToBeCombined,
        ...textAnnotationsToBeCombined,
        LineFootNote(
          order: 300,
          footNote: FootNote(text: 'Test D'),
          locationName: 'Location D',
        ),
        OperationalIndication(order: 400, texts: ['Test E']),
        RuIndication(order: 500, title: 'Title F', text: 'Test F'),
      ];

      // WHEN
      final combinedDataList = baseData.combineFootNoteAndTextAnnotations();

      // THEN
      expect(combinedDataList, hasLength(4));
      final combinedData = combinedDataList.whereType<CombinedFootNoteAndTextAnnotations>().toList();
      expect(combinedData, hasLength(1));
      expect(combinedData[0].footNote, footNoteToBeCombined);
      expect(combinedData[0].textAnnotations, textAnnotationsToBeCombined);
      expect(combinedDataList, isNot(contains(footNoteToBeCombined)));
      expect(combinedDataList, isNot(containsAll(textAnnotationsToBeCombined)));
    },
  );

  test(
    'combineFootNoteAndTextAnnotations_whenOnlyTextAnnotationsWithoutFootNote_combinesThemOnSameLocation',
    () {
      // GIVEN
      final textAnnotationsToBeCombined = [
        OperationalIndication(order: 100, texts: ['Test B']),
        RuIndication(order: 100, title: 'Title C', text: 'Test C'),
        PersonalNoteAnnotation(order: 100, text: 'Test D'),
      ];
      final baseData = <BaseData>[
        ...textAnnotationsToBeCombined,
        LineFootNote(
          order: 300,
          footNote: FootNote(text: 'Test D'),
          locationName: 'Location D',
        ),
        OperationalIndication(order: 400, texts: ['Test E']),
        RuIndication(order: 500, title: 'Title F', text: 'Test F'),
      ];

      // WHEN
      final combinedDataList = baseData.combineFootNoteAndTextAnnotations();

      // THEN
      expect(combinedDataList, hasLength(4));
      final combinedData = combinedDataList.whereType<CombinedFootNoteAndTextAnnotations>().toList();
      expect(combinedData, hasLength(1));
      expect(combinedData[0].footNote, isNull);
      expect(combinedData[0].textAnnotations, textAnnotationsToBeCombined);
      expect(combinedDataList, isNot(containsAll(textAnnotationsToBeCombined)));
    },
  );

  test('combineFootNoteAndTextAnnotations_givenRuIndicationAndFootNote_combinesThemOnSameLocation', () {
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
    final combinedDataList = baseData.combineFootNoteAndTextAnnotations();

    // THEN
    expect(combinedDataList, hasLength(3));
    final combinedData = combinedDataList.whereType<CombinedFootNoteAndTextAnnotations>().toList();
    expect(combinedData, hasLength(1));
    expect(combinedData[0].footNote, footNoteToBeCombined);
    expect(combinedData[0].textAnnotations, [ruIndicationToBeCombined]);
    expect(combinedDataList, isNot(contains(footNoteToBeCombined)));
    expect(combinedDataList, isNot(contains(ruIndicationToBeCombined)));
  });

  test('combineFootNoteAndTextAnnotations_givenOperationalIndicationAndFootNote_combinesThemOnSameLocation', () {
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
    final combinedDataList = baseData.combineFootNoteAndTextAnnotations();

    // THEN
    expect(combinedDataList, hasLength(3));
    final combinedData = combinedDataList.whereType<CombinedFootNoteAndTextAnnotations>().toList();
    expect(combinedData, hasLength(1));
    expect(combinedData[0].footNote, footNoteToBeCombined);
    expect(combinedData[0].textAnnotations, [operationalIndicationToBeCombined]);
    expect(combinedDataList, isNot(contains(footNoteToBeCombined)));
    expect(combinedDataList, isNot(contains(operationalIndicationToBeCombined)));
  });

  test('combineFootNoteAndTextAnnotations_givenPersonalNoteAnnotationAndFootNote_combinesThemOnSameLocation', () {
    // GIVEN
    final footNoteToBeCombined = LineFootNote(
      order: 100,
      footNote: FootNote(text: 'Test A'),
      locationName: 'Location A',
    );
    final personalNoteToBeCombined = PersonalNoteAnnotation(order: 100, text: 'Test B');
    final baseData = <BaseData>[
      footNoteToBeCombined,
      personalNoteToBeCombined,
      LineFootNote(
        order: 300,
        footNote: FootNote(text: 'Test C'),
        locationName: 'Location C',
      ),
      RuIndication(order: 500, title: 'Title E', text: 'Test E'),
    ];

    // WHEN
    final combinedDataList = baseData.combineFootNoteAndTextAnnotations();

    // THEN
    expect(combinedDataList, hasLength(3));
    final combinedData = combinedDataList.whereType<CombinedFootNoteAndTextAnnotations>().toList();
    expect(combinedData, hasLength(1));
    expect(combinedData[0].footNote, footNoteToBeCombined);
    expect(combinedData[0].textAnnotations, [personalNoteToBeCombined]);
    expect(combinedDataList, isNot(contains(footNoteToBeCombined)));
    expect(combinedDataList, isNot(contains(personalNoteToBeCombined)));
  });
}
