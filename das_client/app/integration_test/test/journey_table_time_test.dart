import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_table/widgets/table/cells/time_cell_body.dart';
import 'package:app/util/format.dart';
import 'package:app/util/time_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test time cells for journey in far future (T4) with planned times only', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T4');

    // test if planned time header label is in table (no operational times)
    final expectedPlannedHeaderLabel = l10n.p_train_journey_table_time_label_planned;
    final timeHeader = find.text(expectedPlannedHeaderLabel);
    expect(timeHeader, findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // two service points have empty times
    final timeCellKey = TimeCellBody.timeCellKey;
    expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: 'Solothurn'), findsNothing);

    expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: 'Solothurn West'), findsNothing);

    // Langendorf should have only departure
    final langendorf = 'Langendorf';
    final expectedTimeLangendorf = Format.plannedTime(DateTime.parse('2025-05-12T16:36:45Z'));

    expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: langendorf), findsOneWidget);
    expect(_findTextInDASTableRowByText(innerText: expectedTimeLangendorf, rowText: langendorf), findsOneWidget);

    // Lommiswil has departure and arrival
    final lommiswil = 'Lommiswil';
    final expectedTimeLommiswil =
        '${Format.plannedTime(DateTime.parse('2025-05-12T16:39:12Z'))}\n'
        '${Format.plannedTime(DateTime.parse('2025-05-12T16:40:12Z'))}';
    expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: lommiswil), findsOneWidget);
    expect(_findTextInDASTableRowByText(innerText: expectedTimeLommiswil, rowText: lommiswil), findsOneWidget);

    // Im Holz (non mandatory stop) has departure
    final holz = 'Im Holz';
    final expectedTimeHolz = Format.plannedTime(DateTime.parse('2025-05-12T16:46:12Z'));
    expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: holz), findsOneWidget);
    expect(_findTextInDASTableRowByText(innerText: expectedTimeHolz, rowText: holz), findsOneWidget);

    // Oberdorf has only arrival
    final oberdorf = 'Oberdorf SO';
    final expectedTimeOberdorf = '${Format.plannedTime(DateTime.parse('2025-05-12T16:48:45Z'))}\n';
    expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: oberdorf), findsOneWidget);
    expect(_findTextInDASTableRowByText(innerText: expectedTimeOberdorf, rowText: oberdorf), findsOneWidget);

    // tap header label to switch to planned times
    await tapElement(tester, timeHeader);

    // test if planned time header label is still in table (does not switch)
    expect(find.text(expectedPlannedHeaderLabel), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('test time cells for journey in near future (T16) with operational and planned times', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T16');

    // test if operational time header label is in table
    final expectedCalculatedHeaderLabel = l10n.p_train_journey_table_time_label_new;
    final timeHeader = find.text(expectedCalculatedHeaderLabel);
    expect(timeHeader, findsOneWidget);

    final scrollableFinder = find.byType(AnimatedList);
    expect(scrollableFinder, findsOneWidget);

    // test if times are displayed correctly
    final timeCellKey = TimeCellBody.timeCellKey;
    // Geneve Aeroport should have only departure operational time
    final geneveAer = 'Genève-Aéroport';
    final expectedTimeGeneveAer = Format.operationalTime(DateTime.parse('2025-05-12T16:14:25Z'));
    expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: geneveAer), findsOneWidget);
    expect(_findTextInDASTableRowByText(innerText: expectedTimeGeneveAer, rowText: geneveAer), findsOneWidget);
    // morges should have empty times since it does not have operational times
    final morges = 'Morges';
    expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: morges), findsNothing);
    // vevey should have single operational arrival in brackets since it's a passing point
    final vevey = 'Vevey';

    await tester.dragUntilVisible(
      findDASTableRowByText(vevey),
      scrollableFinder,
      const Offset(0, -50),
    );
    await tester.pumpAndSettle();

    final expectedTimeVevey = '(${Format.operationalTime(DateTime.parse('2025-05-12T17:28:56Z'))})\n';
    expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: vevey), findsOneWidget);
    expect(_findTextInDASTableRowByText(innerText: expectedTimeVevey, rowText: vevey), findsOneWidget);

    // tap header label to switch to planned times
    await tapElement(tester, timeHeader);

    // test if planned time header label is in table
    final expectedPlannedHeaderLabel = l10n.p_train_journey_table_time_label_planned;
    expect(find.text(expectedPlannedHeaderLabel), findsOneWidget);
    // test if time switched (aeroport)
    final geneveAerPlanned = 'Genève-Aéroport';

    await tester.dragUntilVisible(
      findDASTableRowByText(geneveAerPlanned),
      scrollableFinder,
      const Offset(0, 50),
    );

    await tester.pumpAndSettle();

    final expectedTimeGenAerPlanned = Format.plannedTime(DateTime.parse('2025-05-12T15:13:40Z'));

    if (!tester.any(find.text(expectedPlannedHeaderLabel))) {
      await tapElement(tester, timeHeader);
    }

    expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: geneveAerPlanned), findsOneWidget);
    expect(
      _findTextInDASTableRowByText(innerText: expectedTimeGenAerPlanned, rowText: geneveAerPlanned),
      findsOneWidget,
    );

    // morges
    final morgesPlanned = 'Morges';
    final expectedTimeMorgesPlanned = '(${Format.plannedTime(DateTime.parse('2025-05-12T15:55:23Z'))})\n';
    expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: morgesPlanned), findsOneWidget);
    expect(
      _findTextInDASTableRowByText(innerText: expectedTimeMorgesPlanned, rowText: morgesPlanned),
      findsOneWidget,
    );
    // vevey should have both times in brackets since it's a passing point
    final veveyPlanned = 'Vevey';

    await tester.dragUntilVisible(
      findDASTableRowByText(veveyPlanned),
      scrollableFinder,
      const Offset(0, -50),
    );

    await tester.pumpAndSettle();

    if (!tester.any(find.text(expectedPlannedHeaderLabel))) {
      await tapElement(tester, timeHeader);
    }

    final expectedTimeVeveyPlanned =
        '(${Format.plannedTime(DateTime.parse('2025-05-12T16:28:12Z'))})\n'
        '(${Format.plannedTime(DateTime.parse('2025-05-12T16:29:12Z'))})';
    expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: veveyPlanned), findsOneWidget);
    expect(_findTextInDASTableRowByText(innerText: expectedTimeVeveyPlanned, rowText: veveyPlanned), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets(
    'test auto switch behavior for time cells journey in near future (T9999) with operational and planned times',
    (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T9999');

      // test if operational time header label is in table
      final expectedCalculatedHeaderLabel = l10n.p_train_journey_table_time_label_new;
      final timeHeader = find.text(expectedCalculatedHeaderLabel);
      expect(timeHeader, findsOneWidget);

      // tap header label to switch to planned times
      await tapElement(tester, timeHeader);

      // test if planned time header label is in table
      final expectedPlannedHeaderLabel = l10n.p_train_journey_table_time_label_planned;
      expect(find.text(expectedPlannedHeaderLabel), findsOneWidget);

      final waitTime = DI.get<TimeConstants>().arrivalDepartureOperationalResetSeconds + 1;

      await Future.delayed(Duration(seconds: waitTime));

      await tester.pumpAndSettle();

      expect(find.text(expectedCalculatedHeaderLabel), findsOneWidget);

      await disconnect(tester);
    },
  );

  testWidgets('test departure time is underlined when time reached', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T9999M');

    // wait one second for underline to happen if opened last second of previous minute
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // check Bahnhof A has underlined departure time
    final stationARow = findDASTableRowByText('(Bahnhof A)');
    expect(stationARow, findsOneWidget);

    final stationATimeText = tester.widget<Text>(
      find.descendant(of: stationARow, matching: find.byKey(TimeCellBody.timeCellKey)),
    );
    final hasUnderlinedSpanStationA = _hasAnyUnderlinedTextSpans(stationATimeText);
    expect(hasUnderlinedSpanStationA, isTrue);

    await dragUntilTextInStickyHeader(tester, 'Haltestelle B');

    // check Halt auf Verlangen C has no underlined departure time
    final stationCRow = findDASTableRowByText('Halt auf Verlangen C');
    expect(stationCRow, findsOneWidget);

    final stationCTimeText = tester.widget<Text>(
      find.descendant(of: stationCRow, matching: find.byKey(TimeCellBody.timeCellKey)),
    );
    final hasUnderlinedSpanStationC = _hasAnyUnderlinedTextSpans(stationCTimeText);
    expect(hasUnderlinedSpanStationC, isFalse);

    await disconnect(tester);
  });
}

bool _hasAnyUnderlinedTextSpans(Text stationATimeText) {
  bool hasUnderlinedSpanStationA = false;
  stationATimeText.textSpan?.visitChildren((span) {
    if (span.style?.decoration == TextDecoration.underline) {
      hasUnderlinedSpanStationA = true;
      return false;
    }
    return true;
  });
  return hasUnderlinedSpanStationA;
}

Finder _findByKeyInDASTableRowByText({required Key key, required String rowText}) {
  final row = findDASTableRowByText(rowText);
  expect(row, findsOneWidget);
  return find.descendant(of: row, matching: find.byKey(key));
}

Finder _findTextInDASTableRowByText({required String innerText, required String rowText}) {
  final row = findDASTableRowByText(rowText);
  expect(row, findsOneWidget);
  return find.descendant(of: row, matching: find.text(innerText));
}
