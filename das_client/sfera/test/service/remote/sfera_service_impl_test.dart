import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/sfera_service_impl.dart';
import 'package:sfera/src/data/local/db/repo/sfera_database_repository.dart';
import 'package:uuid/uuid.dart';

import 'sfera_service_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MqttService>(),
  MockSpec<SferaDatabaseRepository>(),
  MockSpec<SferaAuthProvider>(),
])
void main() {
  final OtnId otnId = OtnId(company: 'SBB', operationalTrainNumber: '12345', startDate: DateTime.now());
  late SferaServiceImpl sferaService;
  late MockMqttService mockMqttService;
  late MockSferaDatabaseRepository mockDatabaseRepository;
  late MockSferaAuthProvider mockSferaAuthProvider;

  setUp(() {
    mockMqttService = MockMqttService();
    mockDatabaseRepository = MockSferaDatabaseRepository();
    mockSferaAuthProvider = MockSferaAuthProvider();

    sferaService = SferaServiceImpl(
      mqttService: mockMqttService,
      sferaDatabaseRepository: mockDatabaseRepository,
      sferaAuthProvider: mockSferaAuthProvider,
      deviceId: Uuid().v4(),
    );
  });

  test('should start connecting when connect is called', () async {
    // GIVEN
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);

    // LATER THEN
    expectLater(
      sferaService.stateStream,
      emitsInOrder([
        SferaServiceState.disconnected, // seeded state
        SferaServiceState.connecting,
        SferaServiceState.handshaking,
      ]),
    );

    // WHEN
    await sferaService.connect(otnId);

    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 500));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(mockMqttService.publishMessage(
      any,
      any,
      argThat(contains('</HandshakeRequest>')),
    )).called(1);
  });

  test('should publish disconnected when mqtt connection fails', () async {
    // GIVEN
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => false);

    // LATER THEN
    expectLater(
      sferaService.stateStream,
      emitsInOrder([
        SferaServiceState.disconnected, // seeded state
        SferaServiceState.connecting,
        SferaServiceState.disconnected,
      ]),
    );

    // WHEN
    await sferaService.connect(otnId);

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    expect(sferaService.lastError, SferaError.connectionFailed);
  });

  test('should disconnect and set state to disconnected', () async {
    // WHEN
    await sferaService.disconnect();

    // THEN
    verify(mockMqttService.disconnect()).called(1);
    expect(sferaService.stateStream, emits(SferaServiceState.disconnected));
  });
}
