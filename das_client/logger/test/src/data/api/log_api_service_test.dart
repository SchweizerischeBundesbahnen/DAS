import 'package:flutter_test/flutter_test.dart';
import 'package:http_x/component.dart';
import 'package:logger/src/data/api/log_api_service.dart';
import 'package:logger/src/data/dto/log_entry_dto.dart';
import 'package:logger/src/data/mappers.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<Client>(), MockSpec<Response>()])
import 'log_api_service_test.mocks.dart';
import 'response.fake.dart';

void main() {
  const baseUrl = 'example.com';
  late MockClient mockClient;
  late LogApiService testee;

  setUp(() {
    mockClient = MockClient();
    testee = LogApiService(baseUrl: baseUrl, httpClient: mockClient);
  });

  test('sendLogs_whenCalledWithSuccess_makesPostAndHasExpectedHeaders', () async {
    // ARRANGE
    final logEntries = _createDummyLogEntries();

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
    final response = await testee.sendLogs(logEntries);

    // EXPECT
    expect(response.headers, equals(expectedHeaders));

    final expectedUrl = Uri.https(baseUrl, '/v1/logging/logs');
    verify(
      mockClient.post(
        expectedUrl,
        headers: {'Content-Type': 'application/json'},
        body: logEntries.toJsonString(),
      ),
    ).called(1);
  });

  test('sendLogs_whenResponseIsInvalid_shouldThrowHttpException', () async {
    // ARRANGE
    final logEntries = _createDummyLogEntries();

    badRequestResponse(Request request) => FakeResponse(
          statusCode: 400,
          headers: const {},
          body: '{"error": "Bad Request"}',
          request: request,
        );

    when(
      mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer((inv) async => badRequestResponse(Request('post', inv.positionalArguments[0])));

    // ACT & EXPECT
    try {
      await testee.sendLogs(logEntries);
      fail('Expected a BadRequestException to be thrown.');
    } catch (e) {
      expect(e, isA<BadRequestException>());
    }
  });
}

List<LogEntryDto> _createDummyLogEntries() {
  return <LogEntryDto>[
    LogEntryDto(
      source: 'DummySource',
      time: 100,
      level: 'warn',
      message: 'Dummy log entry',
      metadata: {},
    ),
  ];
}
