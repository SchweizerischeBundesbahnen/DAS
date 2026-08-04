import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/chronograph_header_box.dart';
import 'package:app/pages/journey/journey_screen/widgets/floating_departure_checklist_button.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../integration/integration_test_app.dart';
import '../mocks/mock_ru_feature_provider.dart';
import '../util/test_utils.dart';

void main() {
  group('departure process test', () {
    testWidgets('departureProcess_whenFeatureEnabled_thenChecklistButtonDisplayedCorrectly|tests:624,627', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);
      final featureProvider = DI.get<RuFeatureProvider>() as MockRuFeatureProvider;
      featureProvider.enableFeature(.departureProcess);

      await loadJourney(tester, trainNumber: 'T41');

      // start of journey
      await waitUntilExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

      // journey started (exit signal of LZ)
      await waitUntilExists(tester, findChevronPositionAtRowWithText('A1'));
      await waitUntilNotExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

      // next stop reached
      await waitUntilNotExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

      // intermediate signal reached
      await waitUntilExists(tester, findChevronPositionAtRowWithText('I1'));
      await waitUntilExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

      // next signal reached
      await waitUntilNotExists(tester, findChevronPositionAtRowWithText('I1'));
      await waitUntilNotExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

      await disconnect(tester);
    });

    testWidgets(
      'departureProcess_whenNoCustomerOrientedDeparture_thenChecklistButtonOpensDepartureDialog|tests:624,627,148',
      (tester) async {
        await IntegrationTestApp.start(tester);
        final featureProvider = DI.get<RuFeatureProvider>() as MockRuFeatureProvider;
        featureProvider.enableFeature(.departureProcess);

        await loadJourney(tester, trainNumber: 'T41M');

        // start of journey
        await waitUntilExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

        await tapElement(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

        expect(find.text(l10n.w_departure_process_dialog_title), findsOneWidget);
        expect(find.text(l10n.w_departure_process_checklist_item_1), findsOneWidget);
        expect(find.text(l10n.w_departure_process_checklist_item_3), findsOneWidget);

        await disconnect(tester);
      },
    );

    testWidgets('departureProcess_whenFeatureEnabled_thenShowsChronographWarning|tests:627', (tester) async {
      await IntegrationTestApp.start(tester);
      final featureProvider = DI.get<RuFeatureProvider>() as MockRuFeatureProvider;
      featureProvider.enableFeature(.departureProcess);

      await loadJourney(tester, trainNumber: 'T41M');

      // start of journey
      await waitUntilExists(tester, find.byKey(ChronographHeaderBox.warningKey));

      // tap headerbox to toggle warning
      await tapElement(tester, find.byKey(ChronographHeaderBox.warningKey));

      await waitUntilNotExists(tester, find.byKey(ChronographHeaderBox.warningKey));

      // tap headerbox to toggle warning
      await tapElement(tester, find.byKey(ChronographHeaderBox.currentTimeTextKey));

      await waitUntilExists(tester, find.byKey(ChronographHeaderBox.warningKey));

      await disconnect(tester);
    });
  });
}
