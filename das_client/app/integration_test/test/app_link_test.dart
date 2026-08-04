import 'package:app/di/di.dart';
import 'package:app/launcher/launcher.dart';
import 'package:app/model/tour_system.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/journey_identifier.dart';
import 'package:app/pages/journey/journey_screen/widgets/journey_table.dart';
import 'package:app/pages/journey/selection/journey_selection_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/pages/login/widgets/login_button.dart';
import 'package:app/provider/local_key_value_store.dart';
import 'package:app/widgets/navigation_buttons.dart';
import 'package:app_links_x/component.dart';
import 'package:auth/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';
import 'package:train_identification/component.dart';

import '../app_test.dart';
import '../auth/integration_test_authenticator.dart';
import '../integration/integration_test_app.dart';
import '../mocks/mock_app_links_manager.dart';
import '../mocks/mock_launcher.dart';
import '../mocks/mock_local_key_value_store.dart';
import '../mocks/mock_train_identification_repository.dart';
import '../util/test_utils.dart';

void main() {
  group('train-journey app link', () {
    testWidgets('appLink_whenLinkWithSingleTrain_opensJourney|tests:97', (tester) async {
      await IntegrationTestApp.start(tester);

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

      await disconnect(tester);
    });

    testWidgets('appLink_whenLinkWithMultipleTrains_opensFirstJourneyAndRestInNavigation|tests:97', (tester) async {
      await IntegrationTestApp.start(tester);

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

      // check that journeys are loaded by navigating to next journey
      await stopAutomaticAdvancement(tester);
      final nextButton = find.byKey(NavigationButtons.navigationButtonNextKey);
      expect(nextButton, findsOne);
      await tapElement(tester, nextButton);

      // wait until T9999 opened
      await waitUntilExists(
        tester,
        find.descendant(
          of: find.byKey(JourneyIdentifier.journeyIdentifierKey),
          matching: find.textContaining('T9999'),
        ),
      );

      await disconnect(tester);
    });

    testWidgets('appLink_whenLinkWithValidAndUnknownTrain_opensFirstJourneyAndShowsErrorPageForSecond|tests:97', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);

      expect(find.byType(JourneySelectionPage), findsOne);

      final journeys = [
        _trainJourneyLinkData('T1'),
        _trainJourneyLinkData('1234'),
      ];
      _pushTrainJourneyAppLink(journeys);

      // check that first train is loaded
      await waitUntilExists(tester, find.byKey(JourneyTable.loadedJourneyTableKey));
      await tester.pumpAndSettle();
      final trainIdentification = find.descendant(
        of: find.byKey(JourneyIdentifier.journeyIdentifierKey),
        matching: find.textContaining('T1'),
      );
      expect(trainIdentification, findsOne);

      // check error on second journey by navigating
      await stopAutomaticAdvancement(tester);
      final nextButton = find.byKey(NavigationButtons.navigationButtonNextKey);
      expect(nextButton, findsOne);
      await tapElement(tester, nextButton);

      final errorMessage = find.byType(SBBMessage);
      await waitUntilExists(tester, errorMessage);
      await tester.pumpAndSettle();
      final errorMessageText = find.descendant(
        of: errorMessage,
        matching: find.textContaining('${l10n.c_error_code}: ${JpUnavailable().code}'),
      );
      expect(errorMessageText, findsOne);

      await disconnect(tester);
    });

    testWidgets('appLink_whenLinkWhileUnauthenticated_opensJourneyAfterLoginFlow|tests:97', (tester) async {
      await IntegrationTestApp.start(tester);

      expect(find.byType(JourneySelectionPage), findsOne);

      final testAuthenticator = DI.get<Authenticator>() as IntegrationTestAuthenticator;
      testAuthenticator.isAuthenticated = false;

      final journeys = [_trainJourneyLinkData('T9999')];
      _pushTrainJourneyAppLink(journeys);

      // expect link to land on login page as not authenticated
      await waitUntilExists(tester, find.byType(LoginPage));

      // enable connection to mock broker
      // drag bottom sheet
      final title = find.text(l10n.p_login_bottom_sheet_title);
      await tester.drag(title, Offset(0, -150));
      await tester.pumpAndSettle();

      // hit tms toggle to activate mock broker connection
      final tmsToggle = find.text(l10n.p_login_connect_to_tms);
      await tester.tap(tmsToggle);

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

      await disconnect(tester);
    });

    testWidgets('appLink_whenLinkWithUnknownTrain_showsErrorPage|tests:97', (tester) async {
      await IntegrationTestApp.start(tester);

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

    testWidgets('appLink_whenLinkWithTafTapStartAndEnd_showsTrainDriverTurnoverRows|tests:296', (tester) async {
      await IntegrationTestApp.start(tester);

      expect(find.byType(JourneySelectionPage), findsOne);

      final journeys = [_trainJourneyLinkData('T9999M', 'CH09992', 'CH09993')];
      _pushTrainJourneyAppLink(journeys);

      await waitUntilExists(tester, find.byKey(JourneyTable.loadedJourneyTableKey));
      await tester.pumpAndSettle();
      final trainIdentification = find.descendant(
        of: find.byKey(JourneyIdentifier.journeyIdentifierKey),
        matching: find.textContaining('T9999'),
      );
      expect(trainIdentification, findsOne);

      final scrollableFinder = find.byType(AnimatedList);
      await tester.dragUntilVisible(
        findDASTableRowByText(l10n.p_journey_table_curve_type_curve_after_halt),
        scrollableFinder,
        const Offset(0, -50),
      );

      expect(find.text(l10n.w_train_driver_turnover_row_title), findsAny);

      await disconnect(tester);
    });

    testWidgets('appLink_whenLinkWithReturnUrl_shouldUseReturnUrlOverDefaultTourSystemUrl|tests:97,96', (tester) async {
      await IntegrationTestApp.start(tester);

      expect(find.byType(JourneySelectionPage), findsOne);

      final link = 'https://example.com';
      final journeys = [_trainJourneyLinkData('T9999M', 'CH09992', 'CH09993', link)];
      _pushTrainJourneyAppLink(journeys);

      await waitUntilExists(tester, find.byKey(JourneyTable.loadedJourneyTableKey));
      await tester.pumpAndSettle();
      final trainIdentification = find.descendant(
        of: find.byKey(JourneyIdentifier.journeyIdentifierKey),
        matching: find.textContaining('T9999'),
      );
      expect(trainIdentification, findsOne);

      // find pause button and press it
      final pauseButton = find.text(l10n.p_journey_header_button_pause);
      expect(pauseButton, findsOneWidget);
      await tapElement(tester, pauseButton);

      await tapElement(tester, find.text(l10n.p_journey_overview_tour_button_text));

      final userSettings = DI.get<LocalKeyValueStore>() as MockLocalKeyValueStore;
      userSettings.set(.tourSystem, TourSystem.tip.name);

      await tapElement(tester, find.text(l10n.p_journey_overview_tour_button_text));

      final launcher = DI.get<Launcher>() as MockLauncher;
      expect(launcher.launchedUrls, hasLength(2));
      expect(launcher.launchedUrls[0], link);
      expect(launcher.launchedUrls[1], link);

      await disconnect(tester);
    });

    testWidgets('appLink_whenAlreadyOnJourneyPageReceivingDeeplink_opensNewJourney|tests:1852', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9999');

      // check that train is loaded
      await waitUntilExists(tester, find.byKey(JourneyTable.loadedJourneyTableKey));
      await tester.pumpAndSettle();
      final trainIdentification = find.descendant(
        of: find.byKey(JourneyIdentifier.journeyIdentifierKey),
        matching: find.textContaining('T9999'),
      );
      expect(trainIdentification, findsOne);

      final journeys = [_trainJourneyLinkData('T1')];
      _pushTrainJourneyAppLink(journeys);

      // wait until T1 opened
      await waitUntilExists(
        tester,
        find.descendant(
          of: find.byKey(JourneyIdentifier.journeyIdentifierKey),
          matching: find.textContaining('T1'),
        ),
      );

      await disconnect(tester);
    });

    testWidgets('appLink_whenLinkWithSingleTrain_showsCompanyMatchSelection|tests:702', (tester) async {
      await IntegrationTestApp.start(tester);

      expect(find.byType(JourneySelectionPage), findsOne);

      final trainIdentificationRepository =
          DI.get<TrainIdentificationRepository>() as MockTrainIdentificationRepository;
      trainIdentificationRepository.companyMatchData = {
        CompanyMatch(
          ru: RailwayUndertaking.sbbI,
          startDate: DateTime.now(),
        ),
        CompanyMatch(
          ru: RailwayUndertaking.blsI,
          startDate: DateTime.now(),
        ),
      };

      final journeys = [_trainJourneyLinkData('T9999')];
      _pushTrainJourneyAppLink(journeys);

      await waitUntilExists(tester, find.text('5184, SBBI'));
      expect(find.text('2263, BLSI'), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('appLink_whenAlreadyOnJourneyPageReceivingDeeplink_opensSelectionWithCompanyMatch|tests:702', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9999');

      // check that train is loaded
      await waitUntilExists(tester, find.byKey(JourneyTable.loadedJourneyTableKey));
      await tester.pumpAndSettle();
      final trainIdentification = find.descendant(
        of: find.byKey(JourneyIdentifier.journeyIdentifierKey),
        matching: find.textContaining('T9999'),
      );
      expect(trainIdentification, findsOne);

      final trainIdentificationRepository =
          DI.get<TrainIdentificationRepository>() as MockTrainIdentificationRepository;
      trainIdentificationRepository.companyMatchData = {
        CompanyMatch(
          ru: RailwayUndertaking.sbbI,
          startDate: DateTime.now(),
        ),
        CompanyMatch(
          ru: RailwayUndertaking.blsI,
          startDate: DateTime.now(),
        ),
      };

      final journeys = [_trainJourneyLinkData('T1')];
      _pushTrainJourneyAppLink(journeys);

      // wait until SelectionPage is opened
      await waitUntilExists(tester, find.byType(JourneySelectionPage));

      expect(find.text('5184, SBBI'), findsOneWidget);
      expect(find.text('2263, BLSI'), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('appLink_whenAlreadyOnJourneyPageReceivingDeeplink_opensNewJourneyWithMatchingRu|tests:702', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9999');

      // check that train is loaded
      await waitUntilExists(tester, find.byKey(JourneyTable.loadedJourneyTableKey));
      await tester.pumpAndSettle();
      final trainIdentification = find.descendant(
        of: find.byKey(JourneyIdentifier.journeyIdentifierKey),
        matching: find.textContaining('T9999'),
      );
      expect(trainIdentification, findsOne);

      final trainIdentificationRepository =
          DI.get<TrainIdentificationRepository>() as MockTrainIdentificationRepository;
      trainIdentificationRepository.companyMatchData = {
        CompanyMatch(
          ru: RailwayUndertaking.sbbP,
          startDate: DateTime.now(),
        ),
        CompanyMatch(
          ru: RailwayUndertaking.blsI,
          startDate: DateTime.now(),
        ),
      };

      final journeys = [_trainJourneyLinkData('T1')];
      _pushTrainJourneyAppLink(journeys);

      // wait until T1 opened
      await waitUntilExists(
        tester,
        find.descendant(
          of: find.byKey(JourneyIdentifier.journeyIdentifierKey),
          matching: find.textContaining('T1'),
        ),
      );

      await disconnect(tester);
    });
  });
}

TrainJourneyLinkData _trainJourneyLinkData(
  String trainNumber, [
  String? tafTapLocationReferenceStart,
  String? tafTapLocationReferenceEnd,
  String? returnUrl,
  String? company,
]) {
  return TrainJourneyLinkData(
    operationalTrainNumber: trainNumber,
    company: company,
    startDate: DateTime.now(),
    tafTapLocationReferenceStart: tafTapLocationReferenceStart,
    tafTapLocationReferenceEnd: tafTapLocationReferenceEnd,
    returnUrl: returnUrl,
  );
}

void _pushTrainJourneyAppLink(List<TrainJourneyLinkData> journeys) {
  final appLinksManager = DI.get<AppLinksManager>() as MockAppLinksManager;
  final intent = TrainJourneyIntent(appLink: Uri.parse('https://example.com'), journeys: journeys);
  appLinksManager.pushAppLinkIntent(intent);
}
