import 'package:das_client/app/model/train_journey_settings.dart';
import 'package:das_client/model/journey/balise.dart';
import 'package:das_client/model/journey/balise_level_crossing_group.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/base_data_extension.dart';
import 'package:das_client/model/journey/level_crossing.dart';
import 'package:das_client/model/journey/whistles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test balise and level crossing grouping', () {
    final originalRows = <BaseData>[
      Balise(order: 100, kilometre: [0.1], amountLevelCrossings: 1),
      LevelCrossing(order: 101, kilometre: [0.11]),
      Balise(order: 200, kilometre: [0.2], amountLevelCrossings: 1),
      LevelCrossing(order: 202, kilometre: [0.22]),
    ];

    final notExpandedSettings = TrainJourneySettings();
    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings(notExpandedSettings);

    expect(groupedRowsNotExpanded, hasLength(1));
    expect(groupedRowsNotExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(4));

    final expandedSettings = TrainJourneySettings(expandedGroups: [100]);
    final groupedRowsExpanded = originalRows.groupBaliseAndLeveLCrossings(expandedSettings);

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

    final notExpandedSettings = TrainJourneySettings();
    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings(notExpandedSettings);

    expect(groupedRowsNotExpanded, hasLength(2));
    expect(groupedRowsNotExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(2));
    expect(groupedRowsNotExpanded[1], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[1] as BaliseLevelCrossingGroup).groupedElements, hasLength(3));

    final expandedSettings = TrainJourneySettings(expandedGroups: [200]);
    final groupedRowsExpanded = originalRows.groupBaliseAndLeveLCrossings(expandedSettings);

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

    final notExpandedSettings = TrainJourneySettings();
    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings(notExpandedSettings);

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

    final notExpandedSettings = TrainJourneySettings();
    final groupedRowsNotExpanded = originalRows.groupBaliseAndLeveLCrossings(notExpandedSettings);

    expect(groupedRowsNotExpanded, hasLength(1));
    expect(groupedRowsNotExpanded[0], isA<BaliseLevelCrossingGroup>());
    expect((groupedRowsNotExpanded[0] as BaliseLevelCrossingGroup).groupedElements, hasLength(3));
  });
}
