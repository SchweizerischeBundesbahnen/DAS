import 'dart:io';

import 'package:auth/component.dart';
import 'package:connectivity_x/component.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt/component.dart';
import 'package:rxdart/subjects.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/local/drift_sfera_local_database_service.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/repository/sfera_local_repo_impl.dart';
import 'package:sfera/src/data/repository/sfera_repository_impl.dart';
import 'package:uuid/uuid.dart';

import 'sfera_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MqttService>(),
  MockSpec<SferaLocalDatabaseService>(),
  MockSpec<SferaAuthProvider>(),
  MockSpec<SferaLocalRepo>(),
  MockSpec<ConnectivityManager>(),
  MockSpec<Authenticator>(),
])
void main() {
  final TrainIdentification trainId = TrainIdentification(
    companyCode: '1285',
    trainNumber: '12345',
    date: DateTime.now(),
  );
  late SferaRepository testee;
  late MockMqttService mockMqttService;
  late MockSferaLocalDatabaseService mockLocalDatabaseRepository;
  late MockSferaAuthProvider mockSferaAuthProvider;
  late SferaLocalRepo sferaLocalRepo;
  late MockConnectivityManager mockConnectivityManager;
  late MockAuthenticator mockAuthenticator;
  late Subject<bool> reauthenticationRequiredSubject;
  late Subject<String> mqttSubject;
  late Subject<bool> connectivitySubject;

  String loadFile(String path) {
    return File(path).readAsStringSync();
  }

  String wrapReplyMessage(String payloadXml) {
    final normalizedPayload = payloadXml.replaceFirst(RegExp(r'<\?xml[^>]*\?>\s*'), '');
    return '''<?xml version="1.0" encoding="UTF-8"?>
<SFERA_G2B_ReplyMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../SFERA.xsd">
    <MessageHeader SFERA_version="4.00" message_ID="test-message-id" timestamp="2026-01-01T10:52:46Z" sourceDevice="INFRABEL">
        <Sender>0088</Sender>
        <Recipient>1088</Recipient>
    </MessageHeader>
    <G2B_ReplyPayload>
$normalizedPayload
    </G2B_ReplyPayload>
</SFERA_G2B_ReplyMessage>
''';
  }

  setUp(() {
    mockMqttService = MockMqttService();
    mockLocalDatabaseRepository = MockSferaLocalDatabaseService();
    mockSferaAuthProvider = MockSferaAuthProvider();
    sferaLocalRepo = SferaLocalRepoImpl(localService: mockLocalDatabaseRepository);
    mockConnectivityManager = MockConnectivityManager();
    mockAuthenticator = MockAuthenticator();
    reauthenticationRequiredSubject = BehaviorSubject.seeded(false);
    when(mockAuthenticator.reauthenticationRequired).thenAnswer((_) => reauthenticationRequiredSubject.stream);
    mqttSubject = BehaviorSubject<String>();
    connectivitySubject = BehaviorSubject.seeded(false);

    when(mockMqttService.messageStream).thenAnswer((_) => mqttSubject.stream);
    when(mockConnectivityManager.onConnectivityChanged).thenAnswer((_) => connectivitySubject.stream);

    testee = SferaRepoImpl(
      mqttService: mockMqttService,
      localService: mockLocalDatabaseRepository,
      authProvider: mockSferaAuthProvider,
      localRepo: sferaLocalRepo,
      connectivityManager: mockConnectivityManager,
      deviceId: Uuid().v4(),
      authenticator: mockAuthenticator,
      sferaVersion: '4.00',
    );
  });

  test('connect_whenCalled_thenStartsConnecting', () async {
    // GIVEN
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);

    // LATER THEN
    expectLater(
      testee.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
      ]),
    );

    // WHEN
    await testee.connect(trainId);

    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 500));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(
      mockMqttService.publishMessage(
        any,
        any,
        argThat(contains('</DAS_HandshakeRequest>')),
      ),
    ).called(1);
  });

  test('connect_whenMqttConnectionFails_thenPublishesDisconnected', () async {
    // GIVEN
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => false);

    // LATER THEN
    expectLater(
      testee.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .disconnected,
      ]),
    );

    // WHEN
    await testee.connect(trainId);

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    expect(testee.lastError, isA<ConnectionFailed>());
  });

  test('disconnect_whenCalled_thenSetsStateToDisconnected', () async {
    // WHEN
    await testee.disconnect();

    // THEN
    verify(mockMqttService.disconnect()).called(1);
    expect(testee.stateStream, emits(SferaRemoteRepositoryState.disconnected));
  });

  test('connect_whenHandshakeSucceeds_thenStartsLoadingJourneyProfile', () async {
    // GIVEN
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);

    // LATER THEN
    expectLater(
      testee.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
      ]),
    );

    // WHEN
    await testee.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 1));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 1));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(
      mockMqttService.publishMessage(
        any,
        any,
        argThat(contains('</DAS_HandshakeRequest>')),
      ),
    ).called(1);
    verify(
      mockMqttService.publishMessage(
        any,
        any,
        argThat(contains('<JP_Request>')),
      ),
    ).called(1);
  });

  test('connect_whenHandshakeIsRejected_thenDisconnects', () async {
    // GIVEN
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);

    // LATER THEN
    expectLater(
      testee.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .disconnected,
      ]),
    );

    // WHEN
    await testee.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 1));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake_rejected.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 1));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(
      mockMqttService.publishMessage(
        any,
        any,
        argThat(contains('</DAS_HandshakeRequest>')),
      ),
    ).called(1);
  });

  test(
    'connect_whenJourneyProfileResponseIsReceived_thenStartsLoadingSegmentProfilesAndTrainCharacteristics',
    () async {
      // GIVEN
      when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
      when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
      when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);

      // LATER THEN
      expectLater(
        testee.stateStream,
        emitsInOrder(<SferaRemoteRepositoryState>[
          .disconnected, // seeded state
          .connecting,
        ]),
      );

      // WHEN
      await testee.connect(trainId);
      // Wait till async tasks are finished
      await Future.delayed(Duration(milliseconds: 1));

      final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
      mqttSubject.add(handshakeResponse);

      await Future.delayed(Duration(milliseconds: 1));

      final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
      mqttSubject.add(jpResponse);

      await Future.delayed(Duration(milliseconds: 1));

      // THEN
      verify(mockMqttService.connect(any, any)).called(1);
      verify(
        mockMqttService.publishMessage(
          any,
          any,
          argThat(contains('<SP_Request')),
        ),
      ).called(1);
      verify(
        mockMqttService.publishMessage(
          any,
          any,
          argThat(contains('<TC_Request')),
        ),
      ).called(1);
    },
  );

  test('connect_whenSegmentProfileAndTrainCharacteristicsTasksFinish_thenLoadsJourney', () async {
    // GIVEN
    final spResponse = loadFile('test_resources/SFERA_G2B_Reply_SP_request_9315.xml');
    final parsedSPResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(spResponse);
    final tcResponse = loadFile('test_resources/SFERA_G2B_Reply_TC_request_9315.xml');
    final parsedTCResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(tcResponse);

    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);
    when(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).thenAnswer(
      (_) => Future.value(
        SegmentProfileTableData(
          spId: '842-2',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedSPResponse.payload!.segmentProfiles.first.toString(),
        ),
      ),
    );
    when(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).thenAnswer(
      (_) => Future.value(
        TrainCharacteristicsTableData(
          tcId: 'T9135',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedTCResponse.payload!.trainCharacteristics.first.toString(),
        ),
      ),
    );

    // LATER THEN
    expectLater(
      testee.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .connected,
      ]),
    );
    expectLater(
      testee.journeyStream,
      emitsInOrder([
        isNull, // seeded state
        isNotNull,
      ]),
    );

    // WHEN
    await testee.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 1));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 1));

    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
    mqttSubject.add(jpResponse);

    await Future.delayed(Duration(milliseconds: 1));

    mqttSubject.add(spResponse);
    mqttSubject.add(tcResponse);

    await Future.delayed(Duration(milliseconds: 1));
    await Future.delayed(Duration(milliseconds: 1));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).called(2);
    verify(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).called(4);
  });

  test('handleEventMessage_whenJourneyUpdateEventIsReceived_thenRefreshesJourney', () async {
    // GIVEN
    final spResponse = loadFile('test_resources/SFERA_G2B_Reply_SP_request_9315.xml');
    final parsedSPResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(spResponse);
    final tcResponse = loadFile('test_resources/SFERA_G2B_Reply_TC_request_9315.xml');
    final parsedTCResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(tcResponse);

    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);
    when(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).thenAnswer(
      (_) => Future.value(
        SegmentProfileTableData(
          spId: '842-2',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedSPResponse.payload!.segmentProfiles.first.toString(),
        ),
      ),
    );
    when(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).thenAnswer(
      (_) => Future.value(
        TrainCharacteristicsTableData(
          tcId: 'T9135',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedTCResponse.payload!.trainCharacteristics.first.toString(),
        ),
      ),
    );

    // LATER THEN
    expectLater(
      testee.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .connected,
      ]),
    );
    expectLater(
      testee.journeyStream,
      emitsInOrder([
        isNull, // seeded state
        isNotNull,
        isNotNull,
      ]),
    );

    // WHEN
    await testee.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 1));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 1));

    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
    mqttSubject.add(jpResponse);

    await Future.delayed(Duration(milliseconds: 1));

    mqttSubject.add(spResponse);
    mqttSubject.add(tcResponse);

    await Future.delayed(Duration(milliseconds: 1));

    final eventMessage = loadFile('test_resources/SFERA_G2B_EventMessage_9315.xml');
    mqttSubject.add(eventMessage);

    await Future.delayed(Duration(milliseconds: 1));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).called(2);
    verify(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).called(4);
  });

  test(
    'handleEventMessage_whenNewJourneyProfileIsReceived_thenReloadsSegmentProfilesAndTrainCharacteristics',
    () async {
      // GIVEN
      final spResponse = loadFile('test_resources/SFERA_G2B_Reply_SP_request_9315.xml');
      final parsedSPResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(spResponse);
      final tcResponse = loadFile('test_resources/SFERA_G2B_Reply_TC_request_9315.xml');
      final parsedTCResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(tcResponse);

      when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
      when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
      when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);
      when(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).thenAnswer(
        (_) => Future.value(
          SegmentProfileTableData(
            spId: '842-2',
            majorVersion: '1',
            minorVersion: '0',
            xmlData: parsedSPResponse.payload!.segmentProfiles.first.toString(),
          ),
        ),
      );
      when(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).thenAnswer(
        (_) => Future.value(
          TrainCharacteristicsTableData(
            tcId: 'T9135',
            majorVersion: '1',
            minorVersion: '0',
            xmlData: parsedTCResponse.payload!.trainCharacteristics.first.toString(),
          ),
        ),
      );

      // LATER THEN
      expectLater(
        testee.stateStream,
        emitsInOrder(<SferaRemoteRepositoryState>[
          .disconnected, // seeded state
          .connecting,
          .connected,
        ]),
      );
      expectLater(
        testee.journeyStream,
        emitsInOrder([
          isNull, // seeded state
          isNotNull,
          isNotNull,
        ]),
      );

      // WHEN
      await testee.connect(trainId);
      // Wait till async tasks are finished
      await Future.delayed(Duration(milliseconds: 1));

      final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
      mqttSubject.add(handshakeResponse);

      await Future.delayed(Duration(milliseconds: 1));

      final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
      mqttSubject.add(jpResponse);

      await Future.delayed(Duration(milliseconds: 1));

      mqttSubject.add(spResponse);
      mqttSubject.add(tcResponse);

      await Future.delayed(Duration(milliseconds: 1));

      final jpEvent = loadFile('test_resources/SFERA_G2B_Event_JP_9315.xml');
      mqttSubject.add(jpEvent);

      await Future.delayed(Duration(milliseconds: 1));

      // THEN
      verify(mockMqttService.connect(any, any)).called(1);
      verify(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).called(6);
      verify(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).called(7);
    },
  );

  test('disconnect_whenConnected_thenSendsSessionTermination', () async {
    // GIVEN
    final spResponse = loadFile('test_resources/SFERA_G2B_Reply_SP_request_9315.xml');
    final parsedSPResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(spResponse);
    final tcResponse = loadFile('test_resources/SFERA_G2B_Reply_TC_request_9315.xml');
    final parsedTCResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(tcResponse);

    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);
    when(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).thenAnswer(
      (_) => Future.value(
        SegmentProfileTableData(
          spId: '842-2',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedSPResponse.payload!.segmentProfiles.first.toString(),
        ),
      ),
    );
    when(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).thenAnswer(
      (_) => Future.value(
        TrainCharacteristicsTableData(
          tcId: 'T9135',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedTCResponse.payload!.trainCharacteristics.first.toString(),
        ),
      ),
    );

    // LATER THEN
    expectLater(
      testee.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .connected,
        .disconnected,
      ]),
    );
    expectLater(
      testee.journeyStream,
      emitsInOrder([
        isNull, // seeded state
        isNotNull,
        isNotNull,
      ]),
    );

    // WHEN
    await testee.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 1));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 1));

    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
    mqttSubject.add(jpResponse);

    await Future.delayed(Duration(milliseconds: 1));

    mqttSubject.add(spResponse);
    mqttSubject.add(tcResponse);

    await Future.delayed(Duration(milliseconds: 1));

    testee.disconnect();

    await Future.delayed(Duration(milliseconds: 1));

    // THEN
    verify(mockMqttService.disconnect()).called(1);
    verify(
      mockMqttService.publishMessage(
        any,
        any,
        argThat(contains('<SessionTermination')),
      ),
    ).called(1);
  });

  test('connect_whenMqttConnectionFails_thenLoadsOfflineJourney', () async {
    // GIVEN
    final spResponse = loadFile('test_resources/SFERA_G2B_Reply_SP_request_9315.xml');
    final parsedSPResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(spResponse);
    final tcResponse = loadFile('test_resources/SFERA_G2B_Reply_TC_request_9315.xml');
    final parsedTCResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(tcResponse);
    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
    final parsedJPResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(jpResponse);

    when(mockMqttService.connect(any, any)).thenAnswer((_) async => false);
    when(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).thenAnswer(
      (_) => Future.value(
        SegmentProfileTableData(
          spId: '842-2',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedSPResponse.payload!.segmentProfiles.first.toString(),
        ),
      ),
    );
    when(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).thenAnswer(
      (_) => Future.value(
        TrainCharacteristicsTableData(
          tcId: 'T9135',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedTCResponse.payload!.trainCharacteristics.first.toString(),
        ),
      ),
    );
    when(mockLocalDatabaseRepository.findJourneyProfile(any, any, any)).thenAnswer(
      (_) => Future.value(
        JourneyProfileTableData(
          version: '1',
          company: '1085',
          operationalTrainNumber: '123',
          xmlData: parsedJPResponse.payload!.journeyProfiles.first.toString(),
          startDate: DateTime.now(),
        ),
      ),
    );

    // LATER THEN
    expectLater(
      testee.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .offlineData,
      ]),
    );
    expectLater(
      testee.journeyStream,
      emitsInOrder([
        isNull, // seeded state
        isNotNull,
      ]),
    );

    // WHEN
    await testee.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 1));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).called(1);
    verify(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).called(1);
    verify(mockLocalDatabaseRepository.findJourneyProfile(any, any, any)).called(1);

    testee.dispose();
  });

  test('connect_whenTaskFails_thenLoadsOfflineJourney', () async {
    // GIVEN
    final spResponse = loadFile('test_resources/SFERA_G2B_Reply_SP_request_9315.xml');
    final parsedSPResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(spResponse);
    final tcResponse = loadFile('test_resources/SFERA_G2B_Reply_TC_request_9315.xml');
    final parsedTCResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(tcResponse);
    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
    final parsedJPResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(jpResponse);
    final errorResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_Error.xml');

    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);

    when(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).thenAnswer(
      (_) => Future.value(
        SegmentProfileTableData(
          spId: '842-2',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedSPResponse.payload!.segmentProfiles.first.toString(),
        ),
      ),
    );
    when(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).thenAnswer(
      (_) => Future.value(
        TrainCharacteristicsTableData(
          tcId: 'T9135',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedTCResponse.payload!.trainCharacteristics.first.toString(),
        ),
      ),
    );
    when(mockLocalDatabaseRepository.findJourneyProfile(any, any, any)).thenAnswer(
      (_) => Future.value(
        JourneyProfileTableData(
          version: '1',
          company: '1085',
          operationalTrainNumber: '123',
          xmlData: parsedJPResponse.payload!.journeyProfiles.first.toString(),
          startDate: DateTime.now(),
        ),
      ),
    );

    // LATER THEN
    expectLater(
      testee.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .offlineData,
      ]),
    );
    expectLater(
      testee.journeyStream,
      emitsInOrder([
        isNull, // seeded state
        isNotNull,
      ]),
    );

    // WHEN
    await testee.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 1));

    mqttSubject.add(errorResponse);

    await Future.delayed(Duration(milliseconds: 1));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).called(1);
    verify(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).called(1);
    verify(mockLocalDatabaseRepository.findJourneyProfile(any, any, any)).called(1);

    testee.dispose();
  });

  test('connect_whenConnectivityIsAvailableAgain_thenReconnects', () async {
    // GIVEN
    final spResponse = loadFile('test_resources/SFERA_G2B_Reply_SP_request_9315.xml');
    final parsedSPResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(spResponse);
    final tcResponse = loadFile('test_resources/SFERA_G2B_Reply_TC_request_9315.xml');
    final parsedTCResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(tcResponse);
    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
    final parsedJPResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(jpResponse);

    when(mockMqttService.connect(any, any)).thenAnswer((_) async => false);
    when(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).thenAnswer(
      (_) => Future.value(
        SegmentProfileTableData(
          spId: '842-2',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedSPResponse.payload!.segmentProfiles.first.toString(),
        ),
      ),
    );
    when(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).thenAnswer(
      (_) => Future.value(
        TrainCharacteristicsTableData(
          tcId: 'T9135',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedTCResponse.payload!.trainCharacteristics.first.toString(),
        ),
      ),
    );
    when(mockLocalDatabaseRepository.findJourneyProfile(any, any, any)).thenAnswer(
      (_) => Future.value(
        JourneyProfileTableData(
          version: '1',
          company: '1085',
          operationalTrainNumber: '123',
          xmlData: parsedJPResponse.payload!.journeyProfiles.first.toString(),
          startDate: DateTime.now(),
        ),
      ),
    );

    // LATER THEN
    expectLater(
      testee.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .offlineData,
        .connecting,
        .connected,
      ]),
    );
    expectLater(
      testee.journeyStream,
      emitsInOrder([
        isNull, // seeded state
        isNotNull,
        isNotNull,
      ]),
    );

    // WHEN
    await testee.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 1));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).called(1);
    verify(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).called(1);
    verify(mockLocalDatabaseRepository.findJourneyProfile(any, any, any)).called(1);

    reset(mockMqttService);
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);

    // Trigger reconnect
    connectivitySubject.add(true);

    await Future.delayed(Duration(milliseconds: 1));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 1));

    mqttSubject.add(jpResponse);

    await Future.delayed(Duration(milliseconds: 1));

    mqttSubject.add(spResponse);
    mqttSubject.add(tcResponse);

    await Future.delayed(Duration(milliseconds: 1));

    testee.dispose();
  });

  test('connect_whenOnlyPartialSegmentProfilesAreReplied_thenRetriesMaximumNumberOfTimesBeforeAborting', () async {
    // GIVEN
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);

    when(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).thenAnswer((_) async => null);
    when(mockLocalDatabaseRepository.saveSegmentProfile(any)).thenAnswer((_) async {});

    // WHEN
    await testee.connect(trainId);
    await Future.delayed(Duration(milliseconds: 1));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 1));

    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_reply_0001.xml');
    mqttSubject.add(jpResponse);

    await Future.delayed(Duration(milliseconds: 1));

    reset(mockMqttService);

    final spResponse = loadFile('test_resources/SFERA_G2B_Reply_SP_reply_0001_partial_1.xml');
    mqttSubject.add(spResponse);

    await Future.delayed(Duration(milliseconds: 1));
    mqttSubject.add(spResponse);
    await Future.delayed(Duration(milliseconds: 1));
    mqttSubject.add(spResponse);
    await Future.delayed(Duration(milliseconds: 1));
    mqttSubject.add(spResponse);
    await Future.delayed(Duration(milliseconds: 1));

    // THEN
    verify(
      mockMqttService.publishMessage(
        any,
        any,
        argThat(contains('<SP_Request')),
      ),
    ).called(3);

    expectLater(testee.lastError, equals(SferaError.invalid()));
  });

  test('connect_whenSubsequentReplyContainsOtherSegmentProfiles_thenResetsRetryCounter', () async {
    // GIVEN
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);

    when(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).thenAnswer((_) async => null);
    when(mockLocalDatabaseRepository.saveSegmentProfile(any)).thenAnswer((_) async {});

    final spResponse = loadFile('test_resources/SFERA_G2B_Reply_SP_reply_0001_partial_1.xml');
    final parsedSPResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(spResponse);
    final spResponse2 = loadFile('test_resources/SFERA_G2B_Reply_SP_reply_0001_partial_2.xml');
    final parsedSPResponse2 = SferaReplyParser.parse<SferaG2bReplyMessageDto>(spResponse2);

    // WHEN
    await testee.connect(trainId);
    await Future.delayed(Duration(milliseconds: 1));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 1));

    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_reply_0001.xml');
    mqttSubject.add(jpResponse);

    await Future.delayed(Duration(milliseconds: 1));

    reset(mockMqttService);

    mqttSubject.add(spResponse);
    when(mockLocalDatabaseRepository.findSegmentProfile('0001_1', any, any)).thenAnswer(
      (_) => Future.value(
        SegmentProfileTableData(
          spId: '0001_1',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedSPResponse.payload!.segmentProfiles.first.toString(),
        ),
      ),
    );
    await Future.delayed(Duration(milliseconds: 1));

    mqttSubject.add(spResponse);
    await Future.delayed(Duration(milliseconds: 1));

    mqttSubject.add(spResponse);
    await Future.delayed(Duration(milliseconds: 1));

    mqttSubject.add(spResponse2);
    when(mockLocalDatabaseRepository.findSegmentProfile('0001_2', any, any)).thenAnswer(
      (_) => Future.value(
        SegmentProfileTableData(
          spId: '0001_2',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedSPResponse2.payload!.segmentProfiles.first.toString(),
        ),
      ),
    );
    await Future.delayed(Duration(milliseconds: 1));

    mqttSubject.add(spResponse2);
    await Future.delayed(Duration(milliseconds: 1));

    // THEN
    verify(
      mockMqttService.publishMessage(
        any,
        any,
        argThat(contains('<SP_Request')),
      ),
    ).called(5);

    expect(testee.lastError, isNull);

    mqttSubject.add(spResponse2);
    await Future.delayed(Duration(milliseconds: 1));
    mqttSubject.add(spResponse2);
    await Future.delayed(Duration(milliseconds: 1));

    // THEN
    verify(
      mockMqttService.publishMessage(
        any,
        any,
        argThat(contains('<SP_Request')),
      ),
    ).called(1);

    expect(testee.lastError, equals(SferaError.invalid()));
  });

  test('connect_whenOfflineAndReauthenticationRequiredChangesToFalse_thenReconnects', () async {
    // GIVEN
    final spResponse = loadFile('test_resources/SFERA_G2B_Reply_SP_request_9315.xml');
    final parsedSPResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(spResponse);
    final tcResponse = loadFile('test_resources/SFERA_G2B_Reply_TC_request_9315.xml');
    final parsedTCResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(tcResponse);
    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
    final parsedJPResponse = SferaReplyParser.parse<SferaG2bReplyMessageDto>(jpResponse);

    when(mockMqttService.connect(any, any)).thenAnswer((_) async => false);
    when(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).thenAnswer(
      (_) => Future.value(
        SegmentProfileTableData(
          spId: '842-2',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedSPResponse.payload!.segmentProfiles.first.toString(),
        ),
      ),
    );
    when(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).thenAnswer(
      (_) => Future.value(
        TrainCharacteristicsTableData(
          tcId: 'T9135',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedTCResponse.payload!.trainCharacteristics.first.toString(),
        ),
      ),
    );
    when(mockLocalDatabaseRepository.findJourneyProfile(any, any, any)).thenAnswer(
      (_) => Future.value(
        JourneyProfileTableData(
          version: '1',
          company: '1085',
          operationalTrainNumber: '123',
          xmlData: parsedJPResponse.payload!.journeyProfiles.first.toString(),
          startDate: DateTime.now(),
        ),
      ),
    );

    // LATER THEN
    expectLater(
      testee.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .offlineData,
      ]),
    );
    expectLater(
      testee.journeyStream,
      emitsInOrder([
        isNull, // seeded state
        isNotNull,
      ]),
    );

    // WHEN
    await testee.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 1));

    reauthenticationRequiredSubject.add(true);
    await Future.delayed(Duration.zero);
    reauthenticationRequiredSubject.add(false);
    await Future.delayed(Duration.zero);

    // THEN
    verify(mockMqttService.connect(any, any)).called(2);
    verify(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).called(1);
    verify(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).called(1);
    verify(mockLocalDatabaseRepository.findJourneyProfile(any, any, any)).called(1);

    testee.dispose();
  });

  test('connect_whenJourneyIsLoaded_thenRequestsLocalRegulations', () async {
    // GIVEN
    final t26TrainId = TrainIdentification(
      companyCode: '1285',
      trainNumber: 'T26',
      date: DateTime(2025, 6, 17),
    );
    final t26JpResponse = wrapReplyMessage(loadFile('test_resources/T26_local_regulations/SFERA_JP_T26.xml'));
    final spXml = loadFile('test_resources/T26_local_regulations/SFERA_SP_T26_1.xml');
    final spResponse = wrapReplyMessage(spXml);
    final tcXml = loadFile('test_resources/T26_local_regulations/SFERA_TC_T26_1.xml');
    final tcResponse = wrapReplyMessage(tcXml);

    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);
    when(mockLocalDatabaseRepository.findSegmentProfile('T26_1', '1', '0')).thenAnswer(
      (_) async => SegmentProfileTableData(
        spId: 'T26_1',
        majorVersion: '1',
        minorVersion: '0',
        xmlData: spXml,
      ),
    );
    when(mockLocalDatabaseRepository.findSegmentProfile(argThat(startsWith('RL_')), '0', ''))
        .thenAnswer((_) async => null);
    when(mockLocalDatabaseRepository.findTrainCharacteristics('T26_1', '1', '0')).thenAnswer(
      (_) async => TrainCharacteristicsTableData(
        tcId: 'T26_1',
        majorVersion: '1',
        minorVersion: '0',
        xmlData: tcXml,
      ),
    );

    // LATER THEN
    expectLater(
      testee.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .connected,
      ]),
    );
    expectLater(
      testee.journeyStream,
      emitsInOrder([
        isNull, // seeded state
        isNotNull,
      ]),
    );

    // WHEN
    await testee.connect(t26TrainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 1));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 1));

    mqttSubject.add(t26JpResponse);

    await Future.delayed(Duration(milliseconds: 1));

    mqttSubject.add(spResponse);
    mqttSubject.add(tcResponse);

    await Future.delayed(Duration(milliseconds: 1));
    await Future.delayed(Duration(milliseconds: 1));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);

    final publishedMessages = verify(mockMqttService.publishMessage(any, any, captureAny)).captured.cast<String>();
    final localRegulationRequest = publishedMessages.firstWhere(
      (message) =>
          message.contains('SP_ID="RL_701_DE"') &&
          message.contains('SP_ID="RL_702_DE"') &&
          message.contains('SP_ID="RL_703_DE"'),
    );
    expect(localRegulationRequest, contains('<SP_Request'));
    expect(localRegulationRequest, contains('SP_ID="RL_701_DE"'));
    expect(localRegulationRequest, contains('SP_ID="RL_702_DE"'));
    expect(localRegulationRequest, contains('SP_ID="RL_703_DE"'));
    expect(localRegulationRequest, contains('SP_VersionMajor="0"'));
  });
}
