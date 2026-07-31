import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/header/header.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/chronograph_header_box.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/time_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../integration/integration_test_app.dart';
import '../mocks/mock_ru_feature_provider.dart';
import '../util/test_utils.dart';

Future<void> main() async {
  group('chronograph test', () {
    testWidgets('chronograph_whenNoUpdates_thenHidesPunctualityDisplay', (tester) async {
      await IntegrationTestApp.start(tester);

      await loadJourney(tester, trainNumber: 'T4');

      final chronograph = find.byType(ChronographHeaderBox);
      expect(chronograph, findsOneWidget);

      // wait until delay displayed
      await waitUntilExists(
        tester,
        find.descendant(of: chronograph, matching: find.byKey(ChronographHeaderBox.punctualityTextKey)),
      );

      final waitTime = DI.get<TimeConstants>().punctualityDisappearSeconds + 1;

      // wait until waitTime reached
      await tester.pumpAndSettle(Duration(seconds: waitTime));

      // check that delay text has disappeared
      expect(
        find.descendant(of: chronograph, matching: find.byKey(ChronographHeaderBox.punctualityTextKey)),
        findsNothing,
      );
    });

    testWidgets('chronograph_whenNoUpdates_thenPunctualityBecomesStale', (tester) async {
      await IntegrationTestApp.start(tester);

      await loadJourney(tester, trainNumber: 'T4');

      final chronograph = find.byType(ChronographHeaderBox);
      expect(chronograph, findsOneWidget);

      final context = tester.element(chronograph);

      // wait until delay displayed
      await waitUntilExists(tester, find.descendant(of: chronograph, matching: find.text('+00:40')));

      final waitTime = DI.get<TimeConstants>().punctualityStaleSeconds + 1;

      // wait until waitTime reached
      await tester.pumpAndSettle(Duration(seconds: waitTime));

      // check that delay text is stale
      final delayTextWidget = tester.widget<Text>(find.descendant(of: chronograph, matching: find.text('+00:40')));
      expect(delayTextWidget.style?.color, ThemeUtil.getColor(context, SBBColors.graphite, SBBColors.granite));
    });

    testWidgets('chronograph_whenPunctualityUpdateReceived_thenDisplaysCorrectly', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9999');

      // Find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);

      final delayText = '+00:30';
      final delay = find.descendant(of: header, matching: find.text(delayText));

      await waitUntilExists(tester, delay);

      expect(delay, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('chronograph_whenNoCalculatedSpeed_thenHidesPunctuality', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T6');

      // find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);

      await tester.pumpAndSettle();

      // does not find delay text
      expect(find.descendant(of: header, matching: find.byKey(ChronographHeaderBox.punctualityTextKey)), findsNothing);

      await disconnect(tester);
    });

    testWidgets('chronograph_whenNoSferaDelayAvailable_thenShowsPlannedTimeDeviation', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T16');

      final chronograph = find.byType(ChronographHeaderBox);
      expect(chronograph, findsOneWidget);

      final punctualityText = find.descendant(
        of: chronograph,
        matching: find.byKey(ChronographHeaderBox.punctualityTextKey),
      );
      await waitUntilExists(tester, punctualityText);

      final displayedText = tester.widget<Text>(punctualityText).data;
      expect(displayedText, matches(RegExp(r'^[+-]\d{2}h\d{2}$')));

      await disconnect(tester);
    });

    testWidgets('chronograph_whenPlannedTimeDeviationFeatureDisabled_thenNeverShowsDeviation', (tester) async {
      await IntegrationTestApp.start(tester);

      final featureProvider = DI.get<RuFeatureProvider>() as MockRuFeatureProvider;
      featureProvider.disableFeature(.plannedTimeDeviation);

      await loadJourney(tester, trainNumber: 'T16');

      final chronograph = find.byType(ChronographHeaderBox);
      expect(chronograph, findsOneWidget);

      // give the chevron time to advance past the first service point, where a deviation would otherwise show
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(
        find.descendant(of: chronograph, matching: find.byKey(ChronographHeaderBox.punctualityTextKey)),
        findsNothing,
      );

      await disconnect(tester);
    });

    testWidgets('chronograph_whenJourneyLoaded_thenShowsCorrectCurrentTime', (tester) async {
      await IntegrationTestApp.start(tester);

      await loadJourney(tester, trainNumber: 'T6');

      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      final header = find.byType(Header);
      expect(header, findsOneWidget);

      final currentTimeText = tester.widget<Text>(
        find.descendant(of: header, matching: find.byKey(ChronographHeaderBox.currentTimeTextKey)),
      );

      final displayedTime = currentTimeText.data;

      expect(displayedTime, isNotEmpty);

      // compare the range up to three seconds to allow some slack
      final now = tester.binding.clock.now();
      final expectedTime = DateFormat('HH:mm:ss').format(now);

      final displayedDateTime = DateTime.parse('1970-01-01 $displayedTime');
      final expectedDateTime = DateTime.parse('1970-01-01 $expectedTime');

      final difference = displayedDateTime.difference(expectedDateTime).inSeconds.abs();
      expect(difference <= 3, isTrue);

      await disconnect(tester);
    });
  });
}
