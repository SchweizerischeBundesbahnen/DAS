import 'package:das_client/model/journey/balise.dart';
import 'package:das_client/model/journey/balise_level_crossing_group.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/base_data_extension.dart';
import 'package:das_client/model/journey/foot_note.dart';
import 'package:das_client/model/journey/level_crossing.dart';
import 'package:das_client/model/journey/line_foot_note.dart';
import 'package:das_client/model/journey/op_foot_note.dart';
import 'package:das_client/model/journey/signal.dart';
import 'package:das_client/model/journey/track_foot_note.dart';
import 'package:das_client/model/journey/train_series.dart';
import 'package:das_client/model/journey/whistles.dart';
import 'package:das_client/model/localized_string.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test balise and level crossing grouping', () {
    final originalRows = <BaseData>[
      Balise(order: 100, kilometre: [0.1], amountLevelCrossings: 1),
      LevelCrossing(order: 101, kilometre: [0.11]),
      Balise(order: 200, kilometre: [0.2], amountLevelCrossings: 1),
      LevelCrossing(order: 202, kilometre: [0.22]),
    ];

    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings([]).toList();

    expect(groupedRowsNotExpanded, hasLength(1));
    expect(groupedRowsNotExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(4));

    final groupedRowsExpanded = originalRows.groupBaliseAndLeveLCrossings([100]).toList();

    expect(groupedRowsExpanded, hasLength(5));
    expect(groupedRowsExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(4));
    expect(groupedRowsExpanded[1], isA<Balise>());
    expect(groupedRowsExpanded[2], isA<LevelCrossing>());
    expect(groupedRowsExpanded[3], isA<Balise>());
    expect(groupedRowsExpanded[4], isA<LevelCrossing>());
  });

  test('Test balise and level crossing grouping with different amounts', () {
    final originalRows = <BaseData>[
      Balise(order: 100, kilometre: [0.1], amountLevelCrossings: 1),
      LevelCrossing(order: 101, kilometre: [0.11]),
      Balise(order: 200, kilometre: [0.2], amountLevelCrossings: 2),
      LevelCrossing(order: 202, kilometre: [0.22]),
      LevelCrossing(order: 203, kilometre: [0.23]),
    ];

    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings([]).toList();

    expect(groupedRowsNotExpanded, hasLength(2));
    expect(groupedRowsNotExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(2));
    expect(groupedRowsNotExpanded[1], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[1] as BaliseLevelCrossingGroup).groupedElements, hasLength(3));

    final groupedRowsExpanded = originalRows.groupBaliseAndLeveLCrossings([200]).toList();

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

    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings([]).toList();

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

    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings([]).toList();

    expect(groupedRowsNotExpanded, hasLength(1));
    expect(groupedRowsNotExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(3));
  });

  test('Test hide foot notes with non matching train series', () {
    final originalRows = <BaseData>[
      LineFootNote(order: 101, footNote: FootNote(text: 'LineFootNote'), locationName: LocalizedString()),
      OpFootNote(order: 202, footNote: FootNote(text: 'OpFootNote', trainSeries: [TrainSeries.R])),
      TrackFootNote(order: 303, footNote: FootNote(text: 'TrackFootNot')),
    ];

    final filteredRows = originalRows.hideFootNotesForNotSelectedTrainSeries(TrainSeries.N).toList();

    expect(filteredRows, hasLength(2));
    expect(filteredRows[0], isA<LineFootNote>());
    expect(filteredRows[1], isA<TrackFootNote>());
  });

  test('Test do not hide foot notes with matching train series', () {
    final originalRows = <BaseData>[
      LineFootNote(order: 101, footNote: FootNote(text: 'LineFootNote'), locationName: LocalizedString()),
      OpFootNote(order: 202, footNote: FootNote(text: 'OpFootNote', trainSeries: [TrainSeries.R])),
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
      LineFootNote(order: 101, footNote: FootNote(text: 'LineFootNote'), locationName: LocalizedString()),
      OpFootNote(order: 202, footNote: FootNote(text: 'OpFootNote', trainSeries: [TrainSeries.R])),
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
          locationName: LocalizedString()),
      LineFootNote(
          order: 202,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 303,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 404,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 505,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 606,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
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
          locationName: LocalizedString()),
      LineFootNote(
          order: 202,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 303,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 404,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 505,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 606,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
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
          locationName: LocalizedString()),
      LineFootNote(
          order: 202,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 303,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 404,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 505,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 606,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
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
          locationName: LocalizedString()),
      LineFootNote(
          order: 202,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 303,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 404,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 505,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      LineFootNote(
          order: 606,
          footNote: FootNote(text: 'LineFootNote', identifier: identifier),
          locationName: LocalizedString()),
      Signal(order: 800, kilometre: [0.0]),
    ];

    final filteredRows = originalRows.hideRepeatedLineFootNotes(originalRows.last).whereType<LineFootNote>().toList();

    expect(filteredRows, hasLength(1));
    expect(filteredRows[0], isA<LineFootNote>());
    expect(filteredRows[0].order, 606);
  });
}
