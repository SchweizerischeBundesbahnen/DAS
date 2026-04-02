import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/chronograph_header_box.dart';
import 'package:app/pages/journey/journey_screen/widgets/floating_departure_checklist_button.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_chevron.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../mocks/mock_ru_feature_provider.dart';
import '../util/test_utils.dart';

void main() {
  group('departure process test', () {
    testWidgets('test floating departure checklist button displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      final featureProvider = DI.get<RuFeatureProvider>() as MockRuFeatureProvider;
      featureProvider.enableFeature(.departureProcess);

      await loadJourney(tester, trainNumber: 'T41');

      // start of journey
      await waitUntilExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

      // journey started (exit signal of LZ)
      await waitUntilExists(
        tester,
        find.descendant(of: findDASTableRowByText('A1'), matching: find.byKey(RouteChevron.chevronKey)),
      );
      await waitUntilNotExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

      // next stop reached
      await waitUntilNotExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

      // intermediate signal reached
      await waitUntilExists(
        tester,
        find.descendant(of: findDASTableRowByText('I1'), matching: find.byKey(RouteChevron.chevronKey)),
      );
      await waitUntilExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

      // next signal reached
      await waitUntilNotExists(
        tester,
        find.descendant(of: findDASTableRowByText('I1'), matching: find.byKey(RouteChevron.chevronKey)),
      );
      await waitUntilNotExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

      await disconnect(tester);
    });

    testWidgets('test no customer oriented departure button opens dialog', (tester) async {
      await prepareAndStartApp(tester);
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
    });

    testWidgets('test departure chronograph warning is shown', (tester) async {
      await prepareAndStartApp(tester);
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
