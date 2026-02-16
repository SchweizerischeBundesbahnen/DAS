import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/journey_identifier.dart';
import 'package:app/pages/journey/journey_screen/widgets/journey_table.dart';
import 'package:app/pages/journey/selection/journey_selection_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/pages/login/widgets/login_button.dart';
import 'package:app/widgets/navigation_buttons.dart';
import 'package:app_links_x/component.dart';
import 'package:auth/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

import '../app_test.dart';
import '../auth/integrationtest_authenticator.dart';
import '../mocks/mock_app_links_manager.dart';
import '../util/test_utils.dart';

void main() {
  group('train-journey app link', () {
    testWidgets('appLink_whenLinkWithSingleTrain_opensJourney', (tester) async {
      await prepareAndStartApp(tester);

      expect(find.byType(JourneySelectionPage), findsOne);

      final journeys = [_trainJourneyLinkData('T9999')];
      _pushTrainJourneyAppLink(journeys);

      // check that train is loaded
      await waitUntilExists(tester, find.byKey(JourneyTable.loadedJourneyTableKey));
      await tester.pumpAndSettle();
      final trainIdentification = find.descendant(
        of: find.byKey(JourneyIdentifier.journeyIdentifierKey),
        matching: find.textContaining('T9999'),
      );
      expect(trainIdentification, findsOne);

      // check that only one journey is loaded by checking navigation buttons when paused
      await stopAutomaticAdvancement(tester);
      final navigationButtons = find.byKey(NavigationButtons.navigationButtonKey);
      expect(navigationButtons, findsNothing);
    });

    testWidgets('appLink_whenLinkWithMultipleTrain_opensJourneyWithFirstConnectedAndRestInNavigation', (tester) async {
      await prepareAndStartApp(tester);

      expect(find.byType(JourneySelectionPage), findsOne);

      final journeys = [
        _trainJourneyLinkData('1513'),
        _trainJourneyLinkData('T9999'),
      ];
      _pushTrainJourneyAppLink(journeys);

      // check that first train is loaded
      await waitUntilExists(tester, find.byKey(JourneyTable.loadedJourneyTableKey));
      await tester.pumpAndSettle();
      final trainIdentification = find.descendant(
        of: find.byKey(JourneyIdentifier.journeyIdentifierKey),
        matching: find.textContaining('1513'),
      );
      expect(trainIdentification, findsOne);

      // check that journeys are loaded by checking navigation buttons when paused
      await stopAutomaticAdvancement(tester);
      final navigationButtons = find.byKey(NavigationButtons.navigationButtonKey);
      expect(navigationButtons, findsOne);
    });

    testWidgets('appLink_whenLinkWhileUnauthenticated_opensJourneyAfterLoginFlow', (tester) async {
      await prepareAndStartApp(tester);

      expect(find.byType(JourneySelectionPage), findsOne);

      final testAuthenticator = DI.get<Authenticator>() as IntegrationTestAuthenticator;
      testAuthenticator.isAuthenticated = false;

      final journeys = [_trainJourneyLinkData('T9999')];
      _pushTrainJourneyAppLink(journeys);

      // expect link to land on login page as not authenticated
      await waitUntilExists(tester, find.byType(LoginPage));

      // proceed to login
      testAuthenticator.isAuthenticated = true;
      await tapElement(tester, find.byType(LoginButton));

      // expected to land on journey page after login
      await waitUntilExists(tester, find.byKey(JourneyTable.loadedJourneyTableKey));
      await tester.pumpAndSettle();
      final trainIdentification = find.descendant(
        of: find.byKey(JourneyIdentifier.journeyIdentifierKey),
        matching: find.textContaining('T9999'),
      );
      expect(trainIdentification, findsOne);
    });

    testWidgets('appLink_whenLinkWithUnknownTrain_showsErrorPage', (tester) async {
      await prepareAndStartApp(tester);

      expect(find.byType(JourneySelectionPage), findsOne);

      final journeys = [_trainJourneyLinkData('1234')];
      _pushTrainJourneyAppLink(journeys);

      // check that error page is shown
      final errorMessage = find.byType(SBBMessage);
      await waitUntilExists(tester, errorMessage);
      await tester.pumpAndSettle();
      final errorMessageText = find.descendant(
        of: errorMessage,
        matching: find.textContaining('${l10n.c_error_code}: ${JpUnavailable().code}'),
      );
      expect(errorMessageText, findsOne);
    });
  });
}

TrainJourneyLinkData _trainJourneyLinkData(String trainNumber) {
  return TrainJourneyLinkData(
    operationalTrainNumber: trainNumber,
    company: RailwayUndertaking.sbbP.companyCode,
    startDate: DateTime.now(),
  );
}

void _pushTrainJourneyAppLink(List<TrainJourneyLinkData> journeys) {
  final formationRepository = DI.get<AppLinksManager>() as MockAppLinksManager;
  final intent = TrainJourneyIntent(source: Uri.parse('https://example.com'), journeys: journeys);
  formationRepository.pushAppLinkIntent(intent);
}
