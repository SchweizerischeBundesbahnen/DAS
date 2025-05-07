import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/sfera_remote_repo_impl.dart';
import 'package:uuid/uuid.dart';

import 'sfera_remote_repo_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MqttService>(),
  MockSpec<SferaLocalDatabaseService>(),
  MockSpec<SferaAuthProvider>(),
])
void main() {
  final OtnId otnId = OtnId(company: 'SBB', operationalTrainNumber: '12345', startDate: DateTime.now());
  late SferaRemoteRepo sferaRemoteRepo;
  late MockMqttService mockMqttService;
  late MockSferaLocalDatabaseService mockLocalDatabaseRepository;
  late MockSferaAuthProvider mockSferaAuthProvider;

  setUp(() {
    mockMqttService = MockMqttService();
    mockLocalDatabaseRepository = MockSferaLocalDatabaseService();
    mockSferaAuthProvider = MockSferaAuthProvider();

    sferaRemoteRepo = SferaRemoteRepoImpl(
      mqttService: mockMqttService,
      localService: mockLocalDatabaseRepository,
      authProvider: mockSferaAuthProvider,
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
      sferaRemoteRepo.stateStream,
      emitsInOrder([
        SferaRemoteRepositoryState.disconnected, // seeded state
        SferaRemoteRepositoryState.connecting,
        SferaRemoteRepositoryState.handshaking,
      ]),
    );

    // WHEN
    await sferaRemoteRepo.connect(otnId);

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
      sferaRemoteRepo.stateStream,
      emitsInOrder([
        SferaRemoteRepositoryState.disconnected, // seeded state
        SferaRemoteRepositoryState.connecting,
        SferaRemoteRepositoryState.disconnected,
      ]),
    );

    // WHEN
    await sferaRemoteRepo.connect(otnId);

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    expect(sferaRemoteRepo.lastError, SferaError.connectionFailed);
  });

  test('should disconnect and set state to disconnected', () async {
    // WHEN
    await sferaRemoteRepo.disconnect();

    // THEN
    verify(mockMqttService.disconnect()).called(1);
    expect(sferaRemoteRepo.stateStream, emits(SferaRemoteRepositoryState.disconnected));
  });
}
