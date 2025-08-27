import 'package:app/pages/journey/train_journey/widgets/train_journey.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  patrolTest('test breaking series defaults to ??', (tester) async {
    await prepareAndStartApp(tester.tester);

    // load train journey by filling out train selection page
    await loadTrainJourney(tester.tester, trainNumber: 'T6');

    final breakingSeriesHeaderCell = find.byKey(TrainJourney.breakingSeriesHeaderKey);
    expect(breakingSeriesHeaderCell, findsOneWidget);
    expect(find.descendant(of: breakingSeriesHeaderCell, matching: find.text('??')), findsOneWidget);

    await disconnect(tester.tester);
  });

  patrolTest('test default breaking series is taken from train characteristics (R115)', (tester) async {
    await prepareAndStartApp(tester.tester);

    // load train journey by filling out train selection page
    await loadTrainJourney(tester.tester, trainNumber: 'T5');

    final breakingSeriesHeaderCell = find.byKey(TrainJourney.breakingSeriesHeaderKey);
    expect(breakingSeriesHeaderCell, findsOneWidget);
    expect(find.descendant(of: breakingSeriesHeaderCell, matching: find.text('R115')), findsOneWidget);

    await disconnect(tester.tester);
  });

  patrolTest('test all breakseries options are displayed', (tester) async {
    await prepareAndStartApp(tester.tester);

    // load train journey by filling out train selection page
    await loadTrainJourney(tester.tester, trainNumber: 'T5');

    // Open break series bottom sheet
    await tapElement(tester.tester, find.byKey(TrainJourney.breakingSeriesHeaderKey));

    final expectedCategories = {'R', 'A', 'D'};

    for (final entry in expectedCategories) {
      expect(find.text(entry), findsOneWidget);
    }

    final expectedOptions = {
      'R105',
      'R115',
      'R125',
      'R135',
      'R150',
      'A50',
      'A60',
      'A65',
      'A70',
      'A75',
      'A80',
      'A85',
      'A95',
      'A105',
      'A115',
      'D30',
    };

    for (final entry in expectedOptions) {
      expect(find.text(entry), findsAtLeast(1));
    }

    await disconnect(tester.tester);
  });

  patrolTest('test message when no breakseries are defined', (tester) async {
    await prepareAndStartApp(tester.tester);

    // load train journey by filling out train selection page
    await loadTrainJourney(tester.tester, trainNumber: 'T4');

    // Open break series bottom sheet
    await tapElement(tester.tester, find.byKey(TrainJourney.breakingSeriesHeaderKey));

    expect(find.text(l10n.p_train_journey_break_series_empty), findsOneWidget);

    await disconnect(tester.tester);
  });
}
