import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/header/header.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/journey_identifier.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/journey_search_overlay.dart';
import 'package:app/pages/journey/journey_screen/widgets/floating_departure_checklist_button.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../mocks/mock_customer_oriented_departure_repository.dart';
import '../mocks/mock_ru_feature_provider.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test customer oriented departure notifications are displayed properly', (tester) async {
    await prepareAndStartApp(tester);
    final featureProvider = DI.get<RuFeatureProvider>() as MockRuFeatureProvider;
    featureProvider.enableFeature(.departureProcess);
    final mockRepository = DI.get<CustomerOrientedDepartureRepository>() as MockCustomerOrientedDepartureRepository;
    mockRepository.reset();

    final trainNumber = 'T9999M';
    await loadJourney(tester, trainNumber: trainNumber);

    await waitUntilExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

    expect(mockRepository.subscribedTrainNumbers, hasLength(1));
    expect(mockRepository.subscribedTrainNumbers.elementAt(0), trainNumber);
    expect(mockRepository.unsubscribeCallCount, 0);

    mockRepository.emitStatus(CustomerOrientedDeparture(trainNumber: trainNumber, status: .wait));
    await waitUntilExists(tester, find.text(l10n.w_customer_oriented_departure_notification_wait));
    await waitUntilNotExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

    mockRepository.emitStatus(CustomerOrientedDeparture(trainNumber: trainNumber, status: .call));
    await waitUntilExists(tester, find.text(l10n.w_customer_oriented_departure_notification_call));

    // events for other train numbers should be ignored
    mockRepository.emitStatus(CustomerOrientedDeparture(trainNumber: '1234', status: .ready));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(l10n.w_customer_oriented_departure_notification_ready), findsNothing);

    mockRepository.emitStatus(CustomerOrientedDeparture(trainNumber: trainNumber, status: .ready));
    await waitUntilExists(tester, find.text(l10n.w_customer_oriented_departure_notification_ready));

    mockRepository.emitStatus(CustomerOrientedDeparture(trainNumber: trainNumber, status: .departure));
    await waitUntilNotExists(tester, find.text(l10n.w_customer_oriented_departure_notification_ready));
    await waitUntilExists(tester, find.byKey(FloatingDepartureChecklistButton.buttonKey));

    await disconnect(tester);
    expect(mockRepository.unsubscribeCallCount, 1);
  });

  testWidgets('test customer oriented departure subscription changes when changing journey', (tester) async {
    await prepareAndStartApp(tester);
    final mockRepository = DI.get<CustomerOrientedDepartureRepository>() as MockCustomerOrientedDepartureRepository;
    mockRepository.reset();

    await loadJourney(tester, trainNumber: 'T9999M');

    expect(mockRepository.subscribedTrainNumbers, hasLength(1));
    expect(mockRepository.subscribedTrainNumbers.elementAt(0), 'T9999M');
    expect(mockRepository.unsubscribeCallCount, 0);

    await _openJourneyOverSearchOverlay(tester, trainNumber: 'T1M');

    expect(mockRepository.subscribedTrainNumbers, hasLength(2));
    expect(mockRepository.subscribedTrainNumbers.elementAt(0), 'T9999M');
    expect(mockRepository.subscribedTrainNumbers.elementAt(1), 'T1M');
    expect(mockRepository.unsubscribeCallCount, 1);

    await disconnect(tester);
    expect(mockRepository.unsubscribeCallCount, 2);
  });
}

Future<void> _openJourneyOverSearchOverlay(WidgetTester tester, {required String trainNumber}) async {
  final journeySearchOverlay = find.byType(JourneySearchOverlay);
  final journeyIdentifier = find.descendant(
    of: journeySearchOverlay,
    matching: find.byKey(JourneyIdentifier.journeyIdentifierKey),
  );
  await tapElement(tester, journeyIdentifier, warnIfMissed: false);
  await Future.delayed(const Duration(milliseconds: 250));

  final trainNumberText = findTextFieldByHint(l10n.p_train_selection_trainnumber_description);
  await enterText(tester, trainNumberText, trainNumber);

  // load Journey
  final primaryButton = find.descendant(
    of: journeySearchOverlay,
    matching: find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first,
  );
  await tapElement(tester, primaryButton);

  // wait until journey opened
  await waitUntilExists(
    tester,
    find.descendant(of: find.byType(Header), matching: find.text('$trainNumber ${l10n.c_ru_sbb_p}')),
  );
  await tester.pumpAndSettle();
}
