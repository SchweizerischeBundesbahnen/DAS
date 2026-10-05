import 'package:app/pages/journey/journey_page.dart';
import 'package:app/pages/journey/journey_screen/header/header.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/journey_identifier.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/journey_search_overlay.dart';
import 'package:app/pages/journey/selection/journey_selection_page.dart';
import 'package:app/pages/journey/widgets/close_journey_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../integration/integration_test_app.dart';
import '../mocks/mock_settings_repository.dart';
import '../util/test_utils.dart';

void main() {
  group('close journey tests', () {
    testWidgets('closeJourney_whenTrainNotInMotion_thenClosesWithoutConfirmation|ozoPj2dv77YjMngGFB3L|tests:2219', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9999M');

      // train has not departed from the first service point yet
      await stopAutomaticAdvancement(tester);
      await tapElement(tester, find.byKey(JourneyPage.disconnectButtonKey));

      expect(find.text(l10n.w_close_journey_dialog_title), findsNothing);
      await waitUntilExists(tester, find.byType(JourneySelectionPage));
    });

    testWidgets('closeJourney_whenTrainInMotionAndDismissed_thenStaysOnJourney|l0SDAY1hfFdW8kZ5W4uq|tests:2219', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9999M');
      await _moveTrainInMotion(tester);

      await stopAutomaticAdvancement(tester);
      await tapElement(tester, find.byKey(JourneyPage.disconnectButtonKey));

      // modal is displayed with the texts from the acceptance criteria
      expect(find.text(l10n.w_close_journey_dialog_title), findsOneWidget);
      expect(find.text(l10n.w_close_journey_dialog_subTitle), findsOneWidget);
      expect(find.text(l10n.w_close_journey_dialog_cancel_button_labelText), findsOneWidget);
      expect(find.text(l10n.w_close_journey_dialog_confirm_button_labelText), findsOneWidget);

      // cancel
      await tapElement(tester, find.byKey(CloseJourneyDialog.cancelButtonKey));

      expect(find.text(l10n.w_close_journey_dialog_title), findsNothing);
      expect(find.byType(JourneySelectionPage), findsNothing);
      expect(find.byKey(JourneyPage.disconnectButtonKey), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('closeJourney_whenTrainInMotionAndConfirmed_thenClosesJourney|mQdAITcqlVtmatYUWwJJ|tests:2219', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9999M');
      await _moveTrainInMotion(tester);

      await stopAutomaticAdvancement(tester);
      await tapElement(tester, find.byKey(JourneyPage.disconnectButtonKey));
      expect(find.text(l10n.w_close_journey_dialog_title), findsOneWidget);

      // confirm
      await tapElement(tester, find.byKey(CloseJourneyDialog.confirmButtonKey));

      await waitUntilExists(tester, find.byType(JourneySelectionPage));
    });

    testWidgets('journeySearchOverlay_whenOpened_thenShowsNoConfirmation|ImAMqzaTvhzQ6pWsFWPx|tests:2219', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9999M');
      await _moveTrainInMotion(tester);

      // opening the search does not leave the journey yet
      await _openJourneySearchOverlay(tester);

      expect(find.text(l10n.w_close_journey_dialog_title), findsNothing);
      expect(find.byKey(SBBPopover.closeButtonKey), findsAny);

      await disconnect(tester);
    });

    testWidgets(
      'journeySearchOverlay_whenNewTrainLoadedAndDismissed_thenStaysOnJourney|LK3zLOfV6lNG08NYVwB2|tests:2219',
      (tester) async {
        await IntegrationTestApp.start(tester);
        await loadJourney(tester, trainNumber: 'T9999M');
        await _moveTrainInMotion(tester);

        await _openJourneySearchOverlay(tester);
        await _enterTrainNumber(tester, 'T1M');
        await _tapLoadJourneyButton(tester);

        expect(find.text(l10n.w_close_journey_dialog_title), findsOneWidget);

        // cancel - the original journey stays loaded
        await tapElement(tester, find.byKey(CloseJourneyDialog.cancelButtonKey));

        expect(find.text(l10n.w_close_journey_dialog_title), findsNothing);
        expect(_headerTrainIdentifier('T9999M'), findsOneWidget);

        await disconnect(tester);
      },
    );

    testWidgets(
      'journeySearchOverlay_whenDifferentTrainLoadedAndConfirmed_thenLoadsOtherJourney|8b0DxFQyhlwo6oCv6TQw|tests:2219',
      (tester) async {
        await IntegrationTestApp.start(tester);
        await loadJourney(tester, trainNumber: 'T9999M');
        await _moveTrainInMotion(tester);

        await _openJourneySearchOverlay(tester);
        await _enterTrainNumber(tester, 'T1M');
        await _tapLoadJourneyButton(tester);
        expect(find.text(l10n.w_close_journey_dialog_title), findsOneWidget);

        // confirm - the other journey is loaded
        await tapElement(tester, find.byKey(CloseJourneyDialog.confirmButtonKey));

        await waitUntilExists(tester, _headerTrainIdentifier('T1M'));

        await disconnect(tester);
      },
    );
  });
}

Finder _headerTrainIdentifier(String trainNumber) => find.descendant(
  of: find.byType(Header),
  matching: find.text('$trainNumber ${companySBBP.shortName}'),
);

/// Moves the journey position to an intermediate service point, so the train is between the first and the last one.
Future<void> _moveTrainInMotion(WidgetTester tester) async {
  await tester.drag(findDASTableRowByText('Haltestelle B'), const Offset(600, 0));
  await tester.pumpAndSettle();
}

Future<void> _openJourneySearchOverlay(WidgetTester tester) async {
  final journeyIdentifier = find.descendant(
    of: find.byType(JourneySearchOverlay),
    matching: find.byKey(JourneyIdentifier.journeyIdentifierKey),
  );
  await tapElement(tester, journeyIdentifier, warnIfMissed: false);
  await tester.pumpAndSettle(const Duration(milliseconds: 250));
}

Future<void> _enterTrainNumber(WidgetTester tester, String trainNumber) async {
  final trainNumberText = findTextInputByPlaceholder(l10n.p_train_selection_trainnumber_description);
  expect(trainNumberText, findsOneWidget);
  await enterText(tester, trainNumberText, trainNumber);
}

Future<void> _tapLoadJourneyButton(WidgetTester tester) async {
  final loadButton = find.descendant(
    of: find.byType(JourneySearchOverlay),
    matching: find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first,
  );
  await tapElement(tester, loadButton);
}
