import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:app_links_x/component.dart';
import 'package:app_links_x/src/app_links_manager_impl.dart';
import 'package:app_links_x/src/train_journey/train_journey_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import 'app_links_manager_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AppLinks>()])
void main() {
  late AppLinksManagerImpl testee;
  late List<AppLinkIntent> emitRegister;
  late StreamSubscription sub;
  late MockAppLinks mockAppLinks;
  late BehaviorSubject<Uri> mockStream;

  setUp(() {
    mockAppLinks = MockAppLinks();
    mockStream = BehaviorSubject<Uri>();
    when(mockAppLinks.uriLinkStream).thenAnswer((_) => mockStream.stream);
    when(mockAppLinks.getInitialLink()).thenAnswer((_) async => null);

    testee = AppLinksManagerImpl(appLinks: mockAppLinks);
    emitRegister = <AppLinkIntent>[];
    sub = testee.onAppLinkIntent.listen(emitRegister.add);
  });

  tearDown(() async {
    await sub.cancel();
    await mockStream.close();
    testee.dispose();
  });

  test('onTrainJourneyLink_whenInitialLinkGiven_thenEmitLinkData', () async {
    // GIVEN
    final initialUri = _buildTrainJourneyUri(dataJson: _testDataJson);
    when(mockAppLinks.getInitialLink()).thenAnswer((_) async => initialUri);
    final received = <AppLinkIntent>[];

    // WHEN
    // fresh instance for initial link check
    final instance = AppLinksManagerImpl(appLinks: mockAppLinks);
    final sub = instance.onAppLinkIntent.listen(received.add);
    await pumpEventQueue();

    // THEN
    expect(received.length, hasLength(1));
    expect(received.first, isA<TrainJourneyIntent>());
    final intent = received.first as TrainJourneyIntent;
    expect(intent.journeys, hasLength(1));
    _checkDefaultLinkData(intent.journeys.first);

    // DISPOSE
    await sub.cancel();
    instance.dispose();
  });

  test('onTrainJourneyLink_whenLinksOverUriLinkStream_thenEmitLinkData', () async {
    // GIVEN
    final uri1 = _buildTrainJourneyUri(dataJson: _testDataJson);
    final dataJson2 = {
      'journeys': [
        {
          'operationalTrainNumber': '987654321',
          'company': '2185',
        },
      ],
    };
    final uri2 = _buildTrainJourneyUri(dataJson: dataJson2);

    // WHEN
    mockStream.add(uri1);
    mockStream.add(uri2);
    await pumpEventQueue();

    // THEN
    expect(emitRegister, hasLength(2));
    expect(emitRegister[0], isA<TrainJourneyIntent>());
    final intent1 = emitRegister[0] as TrainJourneyIntent;
    expect(intent1.journeys, hasLength(1));
    _checkDefaultLinkData(intent1.journeys.first);

    expect(emitRegister[1], isA<TrainJourneyIntent>());
    final intent2 = emitRegister[1] as TrainJourneyIntent;
    expect(intent2.journeys, hasLength(1));
    final linkData2 = intent2.journeys.first;
    expect(linkData2.company, '2185');
    expect(linkData2.operationalTrainNumber, '987654321');
    expect(linkData2.startDate, isNull);
    expect(linkData2.tafTapLocationReferenceStart, isNull);
    expect(linkData2.tafTapLocationReferenceEnd, isNull);
  });

  test(
    'onTrainJourneyLink_whenEnvOrVersionWrongInUri_thenEmitLinkData',
    () async {
      // GIVEN
      final uri = Uri(
        scheme: 'https',
        host: 'driveradvisorysystem.app.sbb.ch',
        path: '/unknown/test/${TrainJourneyParser.page}',
        queryParameters: {'data': jsonEncode(_testDataJson)},
      );

      // WHEN
      mockStream.add(uri);
      await pumpEventQueue();

      // THEN
      expect(emitRegister.length, hasLength(1));
      expect(emitRegister.first, isA<TrainJourneyIntent>());
      final intent = emitRegister.first as TrainJourneyIntent;
      expect(intent.journeys, hasLength(1));
      _checkDefaultLinkData(intent.journeys.first);
    },
  );

  test('onTrainJourneyLink_whenUriHasWrongHost_thenNoLinkDataEmitted', () async {
    // GIVEN
    final uri = Uri(
      scheme: 'https',
      host: 'other.example.com',
      path: '/dev/v1/${TrainJourneyParser.page}',
      queryParameters: {'data': jsonEncode(_testDataJson)},
    );

    // WHEN
    mockStream.add(uri);
    await pumpEventQueue();

    // THEN
    expect(emitRegister, isEmpty);
  });

  test('onTrainJourneyLink_whenWrongUriSegments_thenNoLinkDataEmitted', () async {
    // GIVEN
    final uri = Uri(
      scheme: 'https',
      host: 'driveradvisorysystem.app.sbb.ch',
      path: '/other/${TrainJourneyParser.page}',
      queryParameters: {'data': jsonEncode(_testDataJson)},
    );

    // WHEN
    mockStream.add(uri);
    await pumpEventQueue();

    // THEN
    expect(emitRegister, isEmpty);
  });

  test('onTrainJourneyLink_whenUriCannotBeParsed_thenNoLinkDataEmitted', () async {
    // GIVEN
    final queryParams = {'data': 'not a json'};
    final uri = _buildTrainJourneyUri(queryParams: queryParams);

    // WHEN
    mockStream.add(uri);
    await pumpEventQueue();

    // THEN
    expect(emitRegister, isEmpty);
  });

  test('onTrainJourneyLink_whenUnknownPage_thenNoLinkDataEmitted', () async {
    // GIVEN
    final uri = _buildTrainJourneyUri(page: 'some-other-page', dataJson: _testDataJson);

    // WHEN
    mockStream.add(uri);
    await pumpEventQueue();

    // THEN
    expect(emitRegister, isEmpty);
  });
}

void _checkDefaultLinkData(TrainJourneyLinkData linkData) {
  expect(linkData.company, _expectedTrainJourneyLinkData.company);
  expect(linkData.operationalTrainNumber, _expectedTrainJourneyLinkData.operationalTrainNumber);
  expect(linkData.startDate, _expectedTrainJourneyLinkData.startDate);
  expect(linkData.tafTapLocationReferenceStart, _expectedTrainJourneyLinkData.tafTapLocationReferenceStart);
  expect(linkData.tafTapLocationReferenceEnd, _expectedTrainJourneyLinkData.tafTapLocationReferenceEnd);
}

TrainJourneyLinkData _expectedTrainJourneyLinkData = TrainJourneyLinkData(
  operationalTrainNumber: '123456789',
  company: '1285',
  startDate: DateTime.parse('2026-01-31'),
  tafTapLocationReferenceStart: 'CH04128',
  tafTapLocationReferenceEnd: 'CH07000',
);

Map<String, Object> _testDataJson = {
  'journeys': [
    {
      'operationalTrainNumber': '123456789',
      'company': '1285',
      'startDate': '2026-01-31',
      'tafTapLocationReferenceStart': 'CH04128',
      'tafTapLocationReferenceEnd': 'CH07000',
    },
  ],
  'returnUrl': 'https://www.sbb.ch',
};

Uri _buildTrainJourneyUri({
  String env = 'dev',
  String version = 'v1',
  String page = TrainJourneyParser.page,
  String host = 'driveradvisorysystem.app.sbb.ch',
  Map<String, dynamic>? dataJson,
  Map<String, dynamic>? queryParams,
}) {
  final params = queryParams ?? (dataJson != null ? {'data': jsonEncode(dataJson)} : null);
  return Uri(
    scheme: 'https',
    host: host,
    path: '/$env/$version/$page',
    queryParameters: params,
  );
}
