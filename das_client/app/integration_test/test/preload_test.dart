import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_page.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_chevron.dart';
import 'package:app/pages/preload/widgets/preload_status_display.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:connectivity_x/component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt/component.dart';
import 'package:preload/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

import '../app_test.dart';
import '../auth/mqtt_client_user_connector.dart';
import '../mocks/mock_connectivity_manager.dart';
import '../mocks/mock_preload_repository.dart';
import '../util/test_utils.dart';

void main() {
  final preloadDetailsIdle = PreloadDetails(
    status: PreloadStatus.idle,
    files: [
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
    ],
    metrics: DbMetrics(jpCount: 43, spCount: 201, tcCount: 33),
  );
  final preloadDetailsRunning = PreloadDetails(
    status: PreloadStatus.running,
    files: [
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.downloaded),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.downloaded),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.downloaded),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.corrupted),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.error),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
    ],
    metrics: DbMetrics(jpCount: 43, spCount: 201, tcCount: 33),
  );
  final preloadDetailsMissingConfiguration = PreloadDetails(
    status: PreloadStatus.missingConfiguration,
    files: [
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.downloaded),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.downloaded),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.downloaded),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.corrupted),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.error),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
      S3File(name: '2026-02-10T16-35-36Z.zip', eTag: 'etag1', size: 1024, status: S3FileSyncStatus.initial),
    ],
    metrics: DbMetrics(jpCount: 43, spCount: 201, tcCount: 33),
  );

  testWidgets('test preload status is displayed correctly', (tester) async {
    await prepareAndStartApp(tester);

    final preloadRepository = DI.get<PreloadRepository>() as MockPreloadRepository;

    // Navigate to preload page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_preload_title));

    final preloadStatusTitleFinder = find.text(l10n.w_preload_status_title);
    expect(preloadStatusTitleFinder, findsOneWidget);

    // Check display with no preload details
    final startButton = find
        .byWidgetPredicate(
          (widget) => widget is SBBTertiaryButtonSmall && widget.label == l10n.w_preload_status_start_preload,
        )
        .first;

    expect(find.text('-'), findsNWidgets(5));
    expect(tester.widget<SBBTertiaryButtonSmall>(startButton).onPressed, isNull);

    // Check display with idle preload details
    preloadRepository.preloadDetailsSubject.add(preloadDetailsIdle);
    await tester.pumpAndSettle();

    expect(find.text('43'), findsOneWidget);
    expect(find.text('201'), findsOneWidget);
    expect(find.text('33'), findsOneWidget);

    expect(find.text('8'), findsOneWidget);
    expect(find.text(l10n.w_preload_status_idle), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is Container && widget.color == PreloadStatusDisplay.initialColor),
      findsNWidgets(2),
    );
    expect(
      find.byWidgetPredicate((widget) => widget is Container && widget.color == PreloadStatusDisplay.downloadedColor),
      findsNWidgets(1),
    );
    expect(
      find.byWidgetPredicate((widget) => widget is Container && widget.color == PreloadStatusDisplay.errorColor),
      findsNWidgets(1),
    );
    expect(tester.widget<SBBTertiaryButtonSmall>(startButton).onPressed, isNotNull);

    // Check display with running preload details
    preloadRepository.preloadDetailsSubject.add(preloadDetailsRunning);
    await tester.pumpAndSettle();

    expect(find.text('3'), findsNWidgets(2));
    expect(find.text('2'), findsOneWidget);
    expect(find.text(l10n.w_preload_status_running), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is Container && widget.color == PreloadStatusDisplay.initialColor),
      findsNWidgets(2),
    );
    expect(
      find.byWidgetPredicate((widget) => widget is Container && widget.color == PreloadStatusDisplay.downloadedColor),
      findsNWidgets(2),
    );
    expect(
      find.byWidgetPredicate((widget) => widget is Container && widget.color == PreloadStatusDisplay.errorColor),
      findsNWidgets(2),
    );
    expect(tester.widget<SBBTertiaryButtonSmall>(startButton).onPressed, isNull);

    // Check display with missing configuration preload details
    preloadRepository.preloadDetailsSubject.add(preloadDetailsMissingConfiguration);
    await tester.pumpAndSettle();

    expect(find.text(l10n.w_preload_status_missing_configuration), findsOneWidget);
    expect(tester.widget<SBBTertiaryButtonSmall>(startButton).onPressed, isNull);
  });

  testWidgets('test preload status is displayed correctly', (tester) async {
    await prepareAndStartApp(tester);

    // Load T9999 so we have it available offline
    await loadJourney(tester, trainNumber: 'T9999', ru: RailwayUndertaking.sbb);
    await stopAutomaticAdvancement(tester);
    await tapElement(tester, find.byKey(JourneyPage.disconnectButtonKey));

    // Force MQTT connection to fail so offline state gets forced;
    final mqttConnector = DI.get<MqttClientConnector>() as MqttClientUserConnector;
    mqttConnector.forceFailToConnect = true;

    final connectivityManager = DI.get<ConnectivityManager>() as MockConnectivityManager;
    connectivityManager.lastConnectedTime = DateTime.now().subtract(Duration(minutes: 2));
    connectivityManager.connectivitySubject.add(false);

    await loadJourney(tester, trainNumber: 'T9999', ru: RailwayUndertaking.sbb);

    // Check if Fahrbild loaded
    expect(find.byType(DASTable), findsOneWidget);
    expect(find.text('(Bahnhof A)'), findsAny);

    // Allow mqtt connection again for other tests
    mqttConnector.forceFailToConnect = false;
    // Force connnection change to trigger reconnect
    connectivityManager.connectivitySubject.add(true);

    // Wait until chevron is on Halt auf Verlangen C
    await waitUntilExists(
      tester,
      find.descendant(of: findDASTableRowByText('Halt auf Verlangen C'), matching: find.byType(RouteChevron)),
    );

    await disconnect(tester);
  });
}
