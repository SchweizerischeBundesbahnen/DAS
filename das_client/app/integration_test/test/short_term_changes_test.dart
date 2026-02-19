import 'package:app/pages/journey/journey_screen/header/header.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/animated_main_headerbox.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/short_term_change_headerbox_flap.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_cell_body.dart';
import 'package:app/widgets/general_short_term_change_indicator.dart';
import 'package:app/widgets/u_turn_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('short term changes tests', () {
    testWidgets('test short term changes are displayed in JourneyTable', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T36M');

      // check station 4 has short term change indicator
      await dragUntilTextInStickyHeader(tester, 'Station 3');
      final stop4Indicator = find.descendant(
        of: findDASTableRowByText('ExceptionalStopStation 4'),
        matching: find.byKey(GeneralShortTermChangeIndicator.indicatorKey),
      );
      expect(stop4Indicator, findsOneWidget);

      // check station 7 has short term change indicator
      await dragUntilTextInStickyHeader(tester, 'Station 6');
      final stop7Indicator = find.descendant(
        of: findDASTableRowByText('SkippedStoppingStation 7'),
        matching: find.byKey(GeneralShortTermChangeIndicator.indicatorKey),
      );
      expect(stop7Indicator, findsOneWidget);

      // check station 10 has short term change indicator
      await dragUntilTextInStickyHeader(tester, 'Station 9');
      final stop10Indicator = find.descendant(
        of: findDASTableRowByText('BeginOfReroutingStation 10'),
        matching: find.byKey(GeneralShortTermChangeIndicator.indicatorKey),
      );
      expect(stop10Indicator, findsOneWidget);

      // check rows have special route cell
      final stop10BeginRouteCellKey = find.descendant(
        of: findDASTableRowByText('BeginOfReroutingStation 10'),
        matching: find.byKey(RouteCellBody.shortTermChangeBeginKey),
      );
      expect(stop10BeginRouteCellKey, findsOneWidget);
      final middleRouteCellKey = find.descendant(
        of: findDASTableRowByText('Station 11'),
        matching: find.byKey(RouteCellBody.shortTermChangeMiddleKey),
      );
      expect(middleRouteCellKey, findsOneWidget);
      final endRouteCellKey = find.descendant(
        of: findDASTableRowByText('Station 12'),
        matching: find.byKey(RouteCellBody.shortTermChangeEndKey),
      );
      expect(endRouteCellKey, findsOneWidget);

      // check station 15 has endDestinationChange indicator
      await dragUntilTextInStickyHeader(tester, 'Station 14');
      final stop15Indicator = find.descendant(
        of: findDASTableRowByText('EndDestinationChangeStation 15'),
        matching: find.byKey(UTurnIndicator.indicatorKey),
      );
      expect(stop15Indicator, findsOneWidget);

      await disconnect(tester);
    });
  });

  testWidgets('test short term changes are displayed in flap', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T36');

    final animatedHeaderbox = find.byType(AnimatedMainHeaderBox);
    final header = find.byType(Header);
    expect(header, findsOneWidget);

    final station1a = find.descendant(of: header, matching: find.text('Station 1A'));
    await waitUntilExists(tester, station1a);

    // has flap from start with multiple changes from start
    final multipleShortTermChanges = find.descendant(
      of: animatedHeaderbox,
      matching: find.byKey(ShortTermChangeHeaderBoxFlap.multipleShortTermChangeKey),
    );
    expect(multipleShortTermChanges, findsOneWidget);

    // has flap when journey begins (for duration)
    final station2 = find.descendant(of: header, matching: find.text('Station 2'));
    await waitUntilExists(tester, station2);
    expect(multipleShortTermChanges, findsOneWidget);

    // flap is hidden after a while due to timed hide®
    await waitUntilNotExists(tester, multipleShortTermChanges, maxWaitSeconds: 5);

    // has flap for passToStop change in station 4
    await waitUntilExists(tester, find.descendant(of: header, matching: find.text('Station 3')));
    final singleShortTermChange = find.descendant(
      of: animatedHeaderbox,
      matching: find.byKey(ShortTermChangeHeaderBoxFlap.singleShortTermChangeKey),
    );
    expect(singleShortTermChange, findsOneWidget);

    // hides flap after passing over station 4
    await waitUntilExists(tester, find.descendant(of: header, matching: find.text('Station 5')));
    final hasShortTermChangeFlap = find.descendant(
      of: animatedHeaderbox,
      matching: find.byKey(ShortTermChangeHeaderBoxFlap.hasShortTermChangeKey),
    );
    expect(hasShortTermChangeFlap, findsNothing);

    await disconnect(tester);
  });
}
