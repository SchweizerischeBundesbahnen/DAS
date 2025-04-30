import 'package:auth/component.dart';
import 'package:app/mqtt/mqtt_component.dart';
import 'package:app/sfera/sfera_component.dart';
import 'package:app/sfera/src/service/remote/sfera_service_impl.dart';
import 'package:app/util/error_code.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sfera_service_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MqttService>(),
  MockSpec<SferaDatabaseRepository>(),
  MockSpec<Authenticator>(),
])
void main() {
  final OtnId otnId = OtnId.create('SBB', '12345', DateTime.now());
  late SferaServiceImpl sferaService;
  late MockMqttService mockMqttService;
  late MockSferaDatabaseRepository mockDatabaseRepository;
  late MockAuthenticator mockAuthenticator;

  setUp(() {
    mockMqttService = MockMqttService();
    mockDatabaseRepository = MockSferaDatabaseRepository();
    mockAuthenticator = MockAuthenticator();

    sferaService = SferaServiceImpl(
      mqttService: mockMqttService,
      sferaDatabaseRepository: mockDatabaseRepository,
      authenticator: mockAuthenticator,
    );
  });

  test('should start connecting when connect is called', () async {
    // GIVEN
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockAuthenticator.user()).thenAnswer((_) async => User(roles: [Role.driver], name: 'Test User'));

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
    expect(sferaService.lastErrorCode, ErrorCode.connectionFailed);
  });

  test('should disconnect and set state to disconnected', () async {
    // WHEN
    await sferaService.disconnect();

    // THEN
    verify(mockMqttService.disconnect()).called(1);
    expect(sferaService.stateStream, emits(SferaServiceState.disconnected));
  });
}
