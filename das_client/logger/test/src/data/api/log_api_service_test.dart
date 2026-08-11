import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http_x/component.dart';
import 'package:logger/component.dart';
import 'package:logger/src/data/api/log_api_service.dart';
import 'package:logger/src/data/api/send_logs_exception.dart';
import 'package:logger/src/data/dto/splunk_log_entry_dto.dart';
import 'package:logger/src/data/mappers.dart';
import 'package:logger/src/log_level.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'log_api_service_test.mocks.dart';
import 'response.fake.dart';

@GenerateNiceMocks([MockSpec<Client>(), MockSpec<Response>(), MockSpec<File>(), MockSpec<LogEndpoint>()])
void main() {
  late MockClient mockClient;
  late LogApiService testee;
  final mockLogEndpoint = MockLogEndpoint();
  final mockUrl = 'https://splunk.sbb.ch/';
  final mockToken = 'dummyToken';
  when(mockLogEndpoint.loggingUrl).thenReturn(mockUrl);
  when(mockLogEndpoint.loggingToken).thenReturn(mockToken);

  setUp(() {
    mockClient = MockClient();
    GetIt.I.registerSingleton<Client>(mockClient);
    testee = LogApiService(httpClient: mockClient);
    GetIt.I.registerSingleton<LogEndpoint>(mockLogEndpoint);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  test('sendLogs_whenCalledWithSuccess_makesPostAndHasExpectedHeaders', () async {
    // ARRANGE
    final logEntries = _createDummyLogEntries();
    final mockFile = MockFile();
    when(mockFile.readAsStringSync()).thenAnswer((_) => logEntries.toJsonString());

    final expectedHeaders = {'Content-Type': 'application/json'};

    successResponse(Request request) => FakeResponse(
      statusCode: 200,
      headers: expectedHeaders,
      body: '{"result": "success"}',
      request: request,
    );

    when(
      mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer((inv) async => successResponse(Request('post', inv.positionalArguments[0])));

    // ACT
    final response = await testee.sendLogs(mockFile);

    // EXPECT
    expect(response.headers, equals(expectedHeaders));

    final expectedUrl = Uri.parse(mockUrl);
    verify(
      mockClient.post(
        expectedUrl,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Splunk $mockToken'},
        body: '[${logEntries.toJsonString()}]',
      ),
    ).called(1);
  });

  test('sendLogs_whenResponseIsBadRequest_shouldThrowPermanentWithHttpExceptionCause', () async {
    // ARRANGE
    final mockFile = _mockLogFile();
    _stubPostWithStatus(mockClient, 400);

    // ACT & EXPECT
    try {
      await testee.sendLogs(mockFile);
      fail('Expected a PermanentSendLogsException to be thrown.');
    } catch (e) {
      expect(e, isA<PermanentSendLogsException>());
      expect((e as PermanentSendLogsException).cause, isA<BadRequestException>());
    }
  });

  for (final statusCode in [400, 404, 413]) {
    test('sendLogs_whenResponseIs${statusCode}_shouldThrowPermanentSendLogsException', () async {
      // ARRANGE
      final mockFile = _mockLogFile();
      _stubPostWithStatus(mockClient, statusCode);

      // ACT & EXPECT
      expect(() => testee.sendLogs(mockFile), throwsA(isA<PermanentSendLogsException>()));
    });
  }

  for (final statusCode in [401, 403, 408, 429, 500, 503]) {
    test('sendLogs_whenResponseIs${statusCode}_shouldThrowTransientSendLogsException', () async {
      // ARRANGE
      final mockFile = _mockLogFile();
      _stubPostWithStatus(mockClient, statusCode);

      // ACT & EXPECT
      expect(() => testee.sendLogs(mockFile), throwsA(isA<TransientSendLogsException>()));
    });
  }

  test('sendLogs_whenPostThrows_shouldThrowTransientSendLogsException', () async {
    // ARRANGE
    final mockFile = _mockLogFile();
    when(
      mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenThrow(const SocketException('no connection'));

    // ACT & EXPECT
    expect(() => testee.sendLogs(mockFile), throwsA(isA<TransientSendLogsException>()));
  });

  test('sendLogs_whenEndpointNotConfigured_shouldThrowTransientSendLogsException', () async {
    // ARRANGE
    final mockFile = _mockLogFile();
    GetIt.I.unregister<LogEndpoint>();

    // ACT & EXPECT
    expect(() => testee.sendLogs(mockFile), throwsA(isA<TransientSendLogsException>()));
    verifyNever(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')));
  });
}

MockFile _mockLogFile() {
  final mockFile = MockFile();
  when(mockFile.readAsStringSync()).thenAnswer((_) => _createDummyLogEntries().toJsonString());
  return mockFile;
}

void _stubPostWithStatus(MockClient mockClient, int statusCode) {
  when(
    mockClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    ),
  ).thenAnswer(
    (inv) async => FakeResponse(
      statusCode: statusCode,
      headers: const {},
      body: '{"text":"No data","code":5}',
      request: Request('post', inv.positionalArguments[0]),
    ),
  );
}

List<SplunkLogEntryDto> _createDummyLogEntries() {
  return <SplunkLogEntryDto>[
    SplunkLogEntryDto(
      time: 100,
      level: LogLevel.warning.name,
      event: 'Dummy log entry',
      fields: {},
    ),
  ];
}
