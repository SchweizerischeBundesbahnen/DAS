import 'dart:async';

import 'package:app/nav/app_link_navigator.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/pages/journey/view_model/model/extended_train_identification.dart';
import 'package:app/pages/journey/view_model/sfera_journey_view_model.dart';
import 'package:app/provider/local_key_value_store.dart';
import 'package:app_links_x/component.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:train_identification/component.dart';

import 'app_link_navigator_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AppLinksManager>(),
  MockSpec<TrainIdentificationRepository>(),
  MockSpec<LocalKeyValueStore>(),
  MockSpec<JourneySelectionViewModel>(),
  MockSpec<JourneyNavigationViewModel>(),
  MockSpec<SferaJourneyViewModel>(),
])
class MockAppRouter extends Mock implements AppRouter {
  final Map<String, bool> activeRoutes = {};
  final List<PageRouteInfo> replacedRoutes = [];

  @override
  bool isRouteActive(String routeName) => activeRoutes[routeName] ?? false;

  @override
  Future<T?> replace<T extends Object?>(
    PageRouteInfo route, {
    OnNavigationFailure? onFailure,
  }) {
    replacedRoutes.add(route);
    return Future<T?>.value();
  }
}

void main() {
  late MockAppLinksManager appLinksManager;
  late MockAppRouter router;
  late MockTrainIdentificationRepository trainIdentificationRepository;
  late MockLocalKeyValueStore mockLocalKeyValueStore;
  late MockJourneySelectionViewModel journeySelectionViewModel;
  late MockJourneyNavigationViewModel journeyNavigationViewModel;
  late StreamController<AppLinkIntent> intentController;
  late AppLinkNavigator testee;

  setUp(() {
    appLinksManager = MockAppLinksManager();
    router = MockAppRouter();
    trainIdentificationRepository = MockTrainIdentificationRepository();
    mockLocalKeyValueStore = MockLocalKeyValueStore();
    journeySelectionViewModel = MockJourneySelectionViewModel();
    journeyNavigationViewModel = MockJourneyNavigationViewModel();
    intentController = StreamController<AppLinkIntent>();

    when(appLinksManager.onAppLinkIntent).thenAnswer((_) => intentController.stream);

    GetIt.I.reset();
    GetIt.I.registerSingleton<TrainIdentificationRepository>(trainIdentificationRepository);
    GetIt.I.registerSingleton<LocalKeyValueStore>(mockLocalKeyValueStore);
    GetIt.I.registerSingleton<JourneySelectionViewModel>(journeySelectionViewModel);
    GetIt.I.registerSingleton<JourneyNavigationViewModel>(journeyNavigationViewModel);
    // Prevent the 500ms startup delay branch in navigator.
    GetIt.I.registerSingleton<SferaJourneyViewModel>(MockSferaJourneyViewModel());

    testee = AppLinkNavigator(
      appLinksManager: appLinksManager,
      router: router,
    );
  });

  tearDown(() async {
    testee.dispose();
    await intentController.close();
    await GetIt.I.reset();
  });

  test('observe_whenKnownCompanyAndJourneyRouteInactive_thenNavigatesToJourneyRoute', () async {
    // ARRANGE
    router.activeRoutes[JourneyRoute.name] = false;

    final linkData = TrainJourneyLinkData(
      operationalTrainNumber: '12345',
      company: '1285',
      startDate: DateTime.utc(2026, 7, 23),
      tafTapLocationReferenceStart: 'A',
      tafTapLocationReferenceEnd: 'B',
      returnUrl: 'https://return.example',
    );
    final journeyIntent = TrainJourneyIntent(appLink: Uri.parse('das://journey'), journeys: [linkData]);

    // ACT
    testee.observe();
    intentController.add(journeyIntent);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // EXPECT
    expect(router.replacedRoutes, hasLength(1));
    final route = router.replacedRoutes.single as JourneyRoute;
    final args = route.args;
    final initialTrainIds = args?.initialTrainIds?.toList() ?? <ExtendedTrainIdentification>[];
    expect(initialTrainIds, hasLength(1));
    expect(
      initialTrainIds.first,
      ExtendedTrainIdentification(
        trainIdentification: TrainIdentification(
          trainNumber: '12345',
          companyCode: '1285',
          date: DateTime.utc(2026, 7, 23),
        ),
        tafTapLocationReferenceStart: 'A',
        tafTapLocationReferenceEnd: 'B',
        returnUrl: 'https://return.example',
      ),
    );
    verifyNever(journeyNavigationViewModel.replaceWith(any));
    verifyNever(journeySelectionViewModel.handleDeepLink(any));
  });

  test('observe_whenKnownCompanyAndJourneyRouteActive_thenReplacesJourneyNavigationStack', () async {
    // ARRANGE
    router.activeRoutes[JourneyRoute.name] = true;

    final linkData = TrainJourneyLinkData(
      operationalTrainNumber: '333',
      company: '1163',
      startDate: DateTime.utc(2026, 7, 20),
    );

    // ACT
    testee.observe();
    intentController.add(TrainJourneyIntent(appLink: Uri.parse('das://journey'), journeys: [linkData]));
    await Future.delayed(Duration.zero);

    // EXPECT
    final captured =
        verify(journeyNavigationViewModel.replaceWith(captureAny)).captured.single
            as Iterable<ExtendedTrainIdentification>;
    final values = captured.toList();
    expect(values, hasLength(1));
    expect(values.first.trainIdentification.companyCode, '1163');
    expect(values.first.trainIdentification.trainNumber, '333');
    expect(router.replacedRoutes, isEmpty);
  });

  test('observe_whenCompanyCannotBeResolved_thenNavigatesToSelectionAndForwardsDeepLink', () async {
    // ARRANGE
    router.activeRoutes[JourneySelectionRoute.name] = false;
    when(mockLocalKeyValueStore.lastUsedCompanyCode).thenReturn(null);
    when(trainIdentificationRepository.findTrainIdentifications(operationalTrainNumber: '777')).thenAnswer(
      (_) async => <CompanyMatch>{},
    );

    final linkData = TrainJourneyLinkData(
      operationalTrainNumber: '777',
      company: null,
      startDate: DateTime.utc(2026, 7, 23),
    );

    // ACT
    testee.observe();
    intentController.add(TrainJourneyIntent(appLink: Uri.parse('das://journey'), journeys: [linkData]));
    await Future.delayed(Duration.zero);

    // EXPECT
    expect(router.replacedRoutes, hasLength(1));
    expect(router.replacedRoutes.single, isA<JourneySelectionRoute>());
    verify(journeySelectionViewModel.handleDeepLink(linkData)).called(1);
    verifyNever(journeyNavigationViewModel.replaceWith(any));
  });
}
