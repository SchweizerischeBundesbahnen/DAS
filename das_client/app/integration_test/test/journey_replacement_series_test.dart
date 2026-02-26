import 'package:app/pages/journey/journey_screen/notification/widgets/replacement_series_notification.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test replacement series is suggested, selected and returned to original', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T30');

    final expectedReplacementSeries = 'R150';
    final originalSeries = 'N180';
    final replacementSeriesFinder = find.byKey(ReplacementSeriesNotification.replacementSeriesAvailableKey);
    await waitUntilExists(tester, replacementSeriesFinder);
    expect(
      find.descendant(of: replacementSeriesFinder, matching: find.textContaining(expectedReplacementSeries)),
      findsOneWidget,
    );

    await selectBrakeSeries(tester, brakeSeries: expectedReplacementSeries);

    replacementSeriesFinder.reset();
    expect(replacementSeriesFinder, findsNothing);

    final originalSeriesFinder = find.byKey(ReplacementSeriesNotification.originalSeriesAvailableKey);
    await waitUntilExists(tester, originalSeriesFinder);
    expect(
      find.descendant(of: originalSeriesFinder, matching: find.textContaining(originalSeries)),
      findsOneWidget,
    );

    await selectBrakeSeries(tester, brakeSeries: originalSeries);
    originalSeriesFinder.reset();
    expect(originalSeriesFinder, findsNothing);

    await disconnect(tester);
  });

  testWidgets('test does not suggest replacement when there is none', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T30');

    final expectedReplacementSeries = 'R150';
    final replacementSeriesFinder = find.byKey(ReplacementSeriesNotification.replacementSeriesAvailableKey);
    await waitUntilExists(tester, replacementSeriesFinder);
    expect(
      find.descendant(of: replacementSeriesFinder, matching: find.textContaining(expectedReplacementSeries)),
      findsOneWidget,
    );

    // Switch to D Series which has no replacement series
    await selectBrakeSeries(tester, brakeSeries: 'D150');
    replacementSeriesFinder.reset();
    expect(replacementSeriesFinder, findsNothing);

    // Switch back to N Series which has a replacement series
    await selectBrakeSeries(tester, brakeSeries: 'N160');
    replacementSeriesFinder.reset();
    await waitUntilExists(tester, replacementSeriesFinder);

    await disconnect(tester);
  });

  testWidgets('test message disappears when end of segment is reached even if user does nothing', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T30');

    await selectBrakeSeries(tester, brakeSeries: 'N160');

    final expectedReplacementSeries = 'R150';
    final replacementSeriesFinder = find.byKey(ReplacementSeriesNotification.replacementSeriesAvailableKey);
    await waitUntilExists(tester, replacementSeriesFinder);
    expect(
      find.descendant(of: replacementSeriesFinder, matching: find.textContaining(expectedReplacementSeries)),
      findsOneWidget,
    );

    replacementSeriesFinder.reset();
    await waitUntilNotExists(tester, replacementSeriesFinder);

    await disconnect(tester);
  });

  testWidgets('test shows no replacement available notification', (
    tester,
  ) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T30M');

    final replacementSeriesFinder = find.byKey(ReplacementSeriesNotification.noReplacementSeriesAvailableKey);
    expect(replacementSeriesFinder, findsNothing);

    await selectBrakeSeries(tester, brakeSeries: 'D150');

    replacementSeriesFinder.reset();
    expect(replacementSeriesFinder, findsOneWidget);

    await selectBrakeSeries(tester, brakeSeries: 'R150');

    replacementSeriesFinder.reset();
    expect(replacementSeriesFinder, findsNothing);

    await disconnect(tester);
  });
}
