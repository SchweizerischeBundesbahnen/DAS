import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  test('Test balise and level crossing grouping', () {
    final originalRows = <BaseData>[
      Balise(order: 100, kilometre: [0.1], amountLevelCrossings: 1),
      LevelCrossing(order: 101, kilometre: [0.11]),
      Balise(order: 200, kilometre: [0.2], amountLevelCrossings: 1),
      LevelCrossing(order: 202, kilometre: [0.22]),
    ];
    final metadata = Metadata(
      levelCrossingGroups: [
        BaliseGroup(
          balise: originalRows[0] as Balise,
          levelCrossings: [originalRows[1] as LevelCrossing],
          otherPoints: [],
        ),
        BaliseGroup(
          balise: originalRows[2] as Balise,
          levelCrossings: [originalRows[3] as LevelCrossing],
          otherPoints: [],
        ),
      ],
    );

    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings([], metadata).toList();

    expect(groupedRowsNotExpanded, hasLength(1));
    expect(groupedRowsNotExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(4));

    final groupedRowsExpanded = originalRows.groupBaliseAndLeveLCrossings([100], metadata).toList();

    expect(groupedRowsExpanded, hasLength(5));
    expect(groupedRowsExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(4));
    expect(groupedRowsExpanded[1], isA<Balise>());
    expect(groupedRowsExpanded[2], isA<LevelCrossing>());
    expect(groupedRowsExpanded[3], isA<Balise>());
    expect(groupedRowsExpanded[4], isA<LevelCrossing>());
  });

  test('Test balise and level crossing grouping with element between balise and level Crossing', () {
    final originalRows = <JourneyPoint>[
      Balise(order: 100, kilometre: [0.1], amountLevelCrossings: 1),
      LevelCrossing(order: 101, kilometre: [0.11]),
      Balise(order: 200, kilometre: [0.2], amountLevelCrossings: 1),
      Signal(order: 201, kilometre: [0.22]),
      LevelCrossing(order: 202, kilometre: [0.22]),
    ];
    final metadata = Metadata(
      levelCrossingGroups: [
        BaliseGroup(
          balise: originalRows[0] as Balise,
          levelCrossings: [originalRows[1] as LevelCrossing],
          otherPoints: [],
        ),
        BaliseGroup(
          balise: originalRows[2] as Balise,
          levelCrossings: [originalRows[4] as LevelCrossing],
          otherPoints: [originalRows[3]],
        ),
      ],
    );

    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings([], metadata).toList();

    expect(groupedRowsNotExpanded, hasLength(2));
    expect(groupedRowsNotExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(4));

    final groupedRowsExpanded = originalRows.groupBaliseAndLeveLCrossings([100], metadata).toList();

    expect(groupedRowsExpanded, hasLength(6));
    expect(groupedRowsExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(4));
    expect(groupedRowsExpanded[1], isA<Balise>());
    expect(groupedRowsExpanded[2], isA<LevelCrossing>());
    expect(groupedRowsExpanded[3], isA<Balise>());
    expect(groupedRowsExpanded[4], isA<LevelCrossing>());
    expect(groupedRowsExpanded[5], isA<Signal>());
  });

  test('Test balise and level crossing not grouping after item between', () {
    final originalRows = <JourneyPoint>[
      Balise(order: 100, kilometre: [0.1], amountLevelCrossings: 1),
      Signal(order: 101, kilometre: [0.22]),
      LevelCrossing(order: 102, kilometre: [0.11]),
      Balise(order: 200, kilometre: [0.2], amountLevelCrossings: 1),
      LevelCrossing(order: 202, kilometre: [0.22]),
    ];
    final metadata = Metadata(
      levelCrossingGroups: [
        BaliseGroup(
          balise: originalRows[0] as Balise,
          levelCrossings: [originalRows[2] as LevelCrossing],
          otherPoints: [originalRows[1]],
        ),
        BaliseGroup(
          balise: originalRows[3] as Balise,
          levelCrossings: [originalRows[4] as LevelCrossing],
          otherPoints: [],
        ),
      ],
    );

    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings([], metadata).toList();

    expect(groupedRowsNotExpanded, hasLength(3));
    expect(groupedRowsNotExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(2));
    expect(groupedRowsNotExpanded[1], isA<Signal>());
    expect(groupedRowsNotExpanded[2], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[2] as BaliseLevelCrossingGroup).groupedElements, hasLength(2));
  });

  test('Test balise and level crossing grouping with different amounts', () {
    final originalRows = <BaseData>[
      Balise(order: 100, kilometre: [0.1], amountLevelCrossings: 1),
      LevelCrossing(order: 101, kilometre: [0.11]),
      Balise(order: 200, kilometre: [0.2], amountLevelCrossings: 2),
      LevelCrossing(order: 202, kilometre: [0.22]),
      LevelCrossing(order: 203, kilometre: [0.23]),
    ];
    final metadata = Metadata(
      levelCrossingGroups: [
        BaliseGroup(
          balise: originalRows[0] as Balise,
          levelCrossings: [originalRows[1] as LevelCrossing],
          otherPoints: [],
        ),
        BaliseGroup(
          balise: originalRows[2] as Balise,
          levelCrossings: [originalRows[3] as LevelCrossing, originalRows[4] as LevelCrossing],
          otherPoints: [],
        ),
      ],
    );

    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings([], metadata).toList();

    expect(groupedRowsNotExpanded, hasLength(2));
    expect(groupedRowsNotExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(2));
    expect(groupedRowsNotExpanded[1], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[1] as BaliseLevelCrossingGroup).groupedElements, hasLength(3));

    final groupedRowsExpanded = originalRows.groupBaliseAndLeveLCrossings([200], metadata).toList();

    expect(groupedRowsExpanded, hasLength(5));
    expect(groupedRowsExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(2));
    expect(groupedRowsExpanded[1], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsExpanded[1] as BaliseLevelCrossingGroup).groupedElements, hasLength(3));
    expect(groupedRowsExpanded[2], isA<Balise>());
    expect(groupedRowsExpanded[3], isA<LevelCrossing>());
    expect(groupedRowsExpanded[4], isA<LevelCrossing>());
  });

  test('Test balise and level crossing grouping with elements between', () {
    final originalRows = <BaseData>[
      Balise(order: 100, kilometre: [0.1], amountLevelCrossings: 1),
      LevelCrossing(order: 101, kilometre: [0.11]),
      Whistle(order: 155, kilometre: [0.22]),
      Balise(order: 200, kilometre: [0.2], amountLevelCrossings: 1),
      LevelCrossing(order: 202, kilometre: [0.22]),
    ];
    final metadata = Metadata(
      levelCrossingGroups: [
        BaliseGroup(
          balise: originalRows[0] as Balise,
          levelCrossings: [originalRows[1] as LevelCrossing],
          otherPoints: [],
        ),
        BaliseGroup(
          balise: originalRows[3] as Balise,
          levelCrossings: [originalRows[4] as LevelCrossing],
          otherPoints: [],
        ),
      ],
    );

    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings([], metadata).toList();

    expect(groupedRowsNotExpanded, hasLength(3));
    expect(groupedRowsNotExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(2));
    expect(groupedRowsNotExpanded[1], isA<Whistle>());
    expect(groupedRowsNotExpanded[2], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[2] as BaliseLevelCrossingGroup).groupedElements, hasLength(2));
  });

  test('Test level crossing grouping', () {
    final originalRows = <BaseData>[
      LevelCrossing(order: 101, kilometre: [0.11]),
      LevelCrossing(order: 202, kilometre: [0.22]),
      LevelCrossing(order: 303, kilometre: [0.33]),
    ];
    final metadata = Metadata(
      levelCrossingGroups: [
        LevelCrossingGroup(
          levelCrossings: originalRows.whereType<LevelCrossing>().toList(),
        ),
      ],
    );

    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings([], metadata).toList();

    expect(groupedRowsNotExpanded, hasLength(1));
    expect(groupedRowsNotExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(3));
  });

  test('Test hide foot notes with non matching train series', () {
    final originalRows = <BaseData>[
      LineFootNote(
        order: 101,
        footNote: FootNote(text: 'LineFootNote'),
        locationName: '',
      ),
      OpFootNote(
        order: 202,
        footNote: FootNote(text: 'OpFootNote', trainSeries: [TrainSeries.R]),
      ),
      TrackFootNote(order: 303, footNote: FootNote(text: 'TrackFootNot')),
    ];

    final filteredRows = originalRows.hideFootNotesForNotSelectedTrainSeries(TrainSeries.N).toList();

    expect(filteredRows, hasLength(2));
    expect(filteredRows[0], isA<LineFootNote>());
    expect(filteredRows[1], isA<TrackFootNote>());
  });

  test('Test do not hide foot notes with matching train series', () {
    final originalRows = <BaseData>[
      LineFootNote(
        order: 101,
        footNote: FootNote(text: 'LineFootNote'),
        locationName: '',
      ),
      OpFootNote(
        order: 202,
        footNote: FootNote(text: 'OpFootNote', trainSeries: [TrainSeries.R]),
      ),
      TrackFootNote(order: 303, footNote: FootNote(text: 'TrackFootNot')),
    ];

    final filteredRows = originalRows.hideFootNotesForNotSelectedTrainSeries(TrainSeries.R).toList();

    expect(filteredRows, hasLength(3));
    expect(filteredRows[0], isA<LineFootNote>());
    expect(filteredRows[1], isA<OpFootNote>());
    expect(filteredRows[2], isA<TrackFootNote>());
  });

  test('Test do not filter foot notes if current train series is null', () {
    final originalRows = <BaseData>[
      LineFootNote(
        order: 101,
        footNote: FootNote(text: 'LineFootNote'),
        locationName: '',
      ),
      OpFootNote(
        order: 202,
        footNote: FootNote(text: 'OpFootNote', trainSeries: [TrainSeries.R]),
      ),
      TrackFootNote(order: 303, footNote: FootNote(text: 'TrackFootNot')),
    ];

    final filteredRows = originalRows.hideFootNotesForNotSelectedTrainSeries(null).toList();

    expect(filteredRows, hasLength(3));
    expect(filteredRows[0], isA<LineFootNote>());
    expect(filteredRows[1], isA<OpFootNote>());
    expect(filteredRows[2], isA<TrackFootNote>());
  });

  test('Test show line foot note with same identifier only once', () {
    final identifier = 'AAAAA-BBBBB-CCCCC';

    final originalRows = <BaseData>[
      LineFootNote(
        order: 101,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 202,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 303,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 404,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 505,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 606,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
    ];

    final filteredRows = originalRows.hideRepeatedLineFootNotes(null).toList();

    expect(filteredRows, hasLength(1));
    expect(filteredRows[0], isA<LineFootNote>());
    expect(filteredRows[0].order, 101);
  });

  test('Test show only the closest line foot note', () {
    final identifier = 'AAAAA-BBBBB-CCCCC';

    final originalRows = <BaseData>[
      LineFootNote(
        order: 101,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 202,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 303,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 404,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 505,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 606,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
    ];

    final filteredRows = originalRows.hideRepeatedLineFootNotes(originalRows[2]).toList();

    expect(filteredRows, hasLength(1));
    expect(filteredRows[0], isA<LineFootNote>());
    expect(filteredRows[0].order, 303);
  });

  test('Test show first line foot note if before', () {
    final identifier = 'AAAAA-BBBBB-CCCCC';

    final originalRows = <BaseData>[
      Signal(order: 100, kilometre: [0.0]),
      LineFootNote(
        order: 101,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 202,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 303,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 404,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 505,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 606,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
    ];

    final filteredRows = originalRows.hideRepeatedLineFootNotes(originalRows[0]).whereType<LineFootNote>().toList();

    expect(filteredRows, hasLength(1));
    expect(filteredRows[0], isA<LineFootNote>());
    expect(filteredRows[0].order, 101);
  });

  test('Test show last line foot note if after', () {
    final identifier = 'AAAAA-BBBBB-CCCCC';

    final originalRows = <BaseData>[
      LineFootNote(
        order: 101,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 202,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 303,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 404,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 505,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      LineFootNote(
        order: 606,
        footNote: FootNote(text: 'LineFootNote', identifier: identifier),
        locationName: '',
      ),
      Signal(order: 800, kilometre: [0.0]),
    ];

    final filteredRows = originalRows.hideRepeatedLineFootNotes(originalRows.last).whereType<LineFootNote>().toList();

    expect(filteredRows, hasLength(1));
    expect(filteredRows[0], isA<LineFootNote>());
    expect(filteredRows[0].order, 606);
  });

  test('Test combine of UncodedOperationalIndication and FootNote on same location', () {
    // GIVEN
    final footNoteToBeCombined = LineFootNote(
      order: 100,
      footNote: FootNote(text: 'Test A'),
      locationName: 'Location A',
    );
    final operationalIndicationToBeCombined = UncodedOperationalIndication(order: 100, texts: ['Test B']);
    final baseData = <BaseData>[
      footNoteToBeCombined,
      operationalIndicationToBeCombined,
      LineFootNote(
        order: 300,
        footNote: FootNote(text: 'Test C'),
        locationName: 'Location C',
      ),
      UncodedOperationalIndication(order: 400, texts: ['Test D']),
    ];

    // WHEN
    final combinedDataList = baseData.combineFootNoteAndOperationalIndication();

    // THEN
    expect(combinedDataList, hasLength(3));
    final combinedData = combinedDataList.whereType<CombinedFootNoteOperationalIndication>().toList();
    expect(combinedData, hasLength(1));
    expect(combinedData[0].footNote, footNoteToBeCombined);
    expect(combinedData[0].operationalIndication, operationalIndicationToBeCombined);
    expect(combinedDataList, isNot(contains(footNoteToBeCombined)));
    expect(combinedDataList, isNot(contains(operationalIndicationToBeCombined)));
  });
}
