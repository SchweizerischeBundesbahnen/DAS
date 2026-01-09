import 'package:app/pages/journey/journey_screen/header/widgets/journey_advancement_button.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_chevron.dart';
import 'package:app/widgets/stickyheader/sticky_header.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('manual advancement tests', () {
    testWidgets('whenServicePointDragged_thenJourneyPositionMoved', skip: true, (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T9999M');

      // Check chevron at start A
      final a = '(Bahnhof A)';
      expect(find.descendant(of: findDASTableRowByText(a), matching: find.byKey(RouteChevron.chevronKey)), findsAny);

      // set position to B manually
      final b = 'Haltestelle B';
      await tester.drag(findDASTableRowByText(b), const Offset(600, 0));
      await tester.pumpAndSettle();

      // Check chevron at B
      expect(
        find.descendant(of: findDASTableRowByText(b), matching: find.byKey(RouteChevron.chevronKey)),
        findsAny,
      );

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      await tester.dragUntilVisible(find.text('S1'), scrollableFinder, const Offset(0, 50));

      // check can dismiss drag gesture
      await tester.drag(
        find.descendant(of: find.byKey(StickyHeader.headerKey), matching: find.text(a)),
        const Offset(150, 0),
      );
      await tester.pumpAndSettle();

      // check chevron not at A
      expect(
        find.descendant(
          of: find.descendant(of: find.byKey(StickyHeader.headerKey), matching: find.text(a)),
          matching: find.byKey(RouteChevron.chevronKey),
        ),
        findsNothing,
      );

      await disconnect(tester);
    });

    testWidgets('whenManualPositionSet_thenManualModeActivatedUntilJourneyPositionSignaled', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T9999');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final b = 'Haltestelle B';
      await tester.dragUntilVisible(find.text(b), scrollableFinder, const Offset(0, -50));

      // set position to B manually
      await tester.drag(findDASTableRowByText(b), const Offset(600, 0));
      await tester.pumpAndSettle();

      // Check chevron at B
      expect(
        find.descendant(of: findDASTableRowByText(b), matching: find.byKey(RouteChevron.chevronKey)),
        findsAny,
      );
      // Check manual mode
      expect(
        find.descendant(
          of: find.byKey(JourneyAdvancementButton.pauseKey),
          matching: find.byIcon(SBBIcons.hand_cursor_small),
        ),
        findsOne,
      );

      // wait until signal received and back to non manual mode
      await waitUntilExists(
        tester,
        find.descendant(of: find.byKey(JourneyAdvancementButton.pauseKey), matching: find.byIcon(SBBIcons.pause_small)),
      );

      await disconnect(tester);
    });
  });
}
