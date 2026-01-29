import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt/component.dart';
import 'package:rxdart/subjects.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/local/drift_local_database_service.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/repository/sfera_remote_repo_impl.dart';
import 'package:uuid/uuid.dart';

import 'sfera_remote_repo_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MqttService>(),
  MockSpec<SferaLocalDatabaseService>(),
  MockSpec<SferaAuthProvider>(),
])
void main() {
  final TrainIdentification trainId = TrainIdentification(
    ru: .sbbP,
    trainNumber: '12345',
    date: DateTime.now(),
  );
  late SferaRemoteRepo sferaRemoteRepo;
  late MockMqttService mockMqttService;
  late MockSferaLocalDatabaseService mockLocalDatabaseRepository;
  late MockSferaAuthProvider mockSferaAuthProvider;
  late Subject<String> mqttSubject;

  String loadFile(String path) {
    return File(path).readAsStringSync();
  }

  setUp(() {
    mockMqttService = MockMqttService();
    mockLocalDatabaseRepository = MockSferaLocalDatabaseService();
    mockSferaAuthProvider = MockSferaAuthProvider();
    mqttSubject = BehaviorSubject<String>();

    when(mockMqttService.messageStream).thenAnswer((_) => mqttSubject.stream);

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
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
      ]),
    );

    // WHEN
    await sferaRemoteRepo.connect(trainId);

    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 500));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(
      mockMqttService.publishMessage(
        any,
        any,
        argThat(contains('</HandshakeRequest>')),
      ),
    ).called(1);
  });

  test('should publish disconnected when mqtt connection fails', () async {
    // GIVEN
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => false);

    // LATER THEN
    expectLater(
      sferaRemoteRepo.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .disconnected,
      ]),
    );

    // WHEN
    await sferaRemoteRepo.connect(trainId);

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    expect(sferaRemoteRepo.lastError, isA<ConnectionFailed>());
  });

  test('should disconnect and set state to disconnected', () async {
    // WHEN
    await sferaRemoteRepo.disconnect();

    // THEN
    verify(mockMqttService.disconnect()).called(1);
    expect(sferaRemoteRepo.stateStream, emits(SferaRemoteRepositoryState.disconnected));
  });

  test('should start loading journey profile after handshake', () async {
    // GIVEN
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);

    // LATER THEN
    expectLater(
      sferaRemoteRepo.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
      ]),
    );

    // WHEN
    await sferaRemoteRepo.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 200));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 200));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(
      mockMqttService.publishMessage(
        any,
        any,
        argThat(contains('</HandshakeRequest>')),
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

  test('should disconnect on handshake reject', () async {
    // GIVEN
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);

    // LATER THEN
    expectLater(
      sferaRemoteRepo.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .disconnected,
      ]),
    );

    // WHEN
    await sferaRemoteRepo.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 200));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake_rejected.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 200));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(
      mockMqttService.publishMessage(
        any,
        any,
        argThat(contains('</HandshakeRequest>')),
      ),
    ).called(1);
  });

  test('should start loading segment profile and train characteristics after jp response', () async {
    // GIVEN
    when(mockMqttService.connect(any, any)).thenAnswer((_) async => true);
    when(mockMqttService.publishMessage(any, any, any)).thenReturn(true);
    when(mockSferaAuthProvider.isDriver()).thenAnswer((_) async => true);

    // LATER THEN
    expectLater(
      sferaRemoteRepo.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
      ]),
    );

    // WHEN
    await sferaRemoteRepo.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 200));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 200));

    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
    mqttSubject.add(jpResponse);

    await Future.delayed(Duration(milliseconds: 200));

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
  });

  test('should be loaded after finishing SP und TC Tasks', () async {
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
          id: 1,
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
          id: 1,
          tcId: 'T9135',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedTCResponse.payload!.trainCharacteristics.first.toString(),
        ),
      ),
    );

    // LATER THEN
    expectLater(
      sferaRemoteRepo.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .connected,
      ]),
    );
    expectLater(
      sferaRemoteRepo.journeyStream,
      emitsInOrder([
        isNull, // seeded state
        isNotNull,
      ]),
    );

    // WHEN
    await sferaRemoteRepo.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 200));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 200));

    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
    mqttSubject.add(jpResponse);

    await Future.delayed(Duration(milliseconds: 200));

    mqttSubject.add(spResponse);
    mqttSubject.add(tcResponse);

    await Future.delayed(Duration(milliseconds: 200));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).called(3);
    verify(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).called(3);
  });

  test('should refresh journey after event', () async {
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
          id: 1,
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
          id: 1,
          tcId: 'T9135',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedTCResponse.payload!.trainCharacteristics.first.toString(),
        ),
      ),
    );

    // LATER THEN
    expectLater(
      sferaRemoteRepo.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .connected,
      ]),
    );
    expectLater(
      sferaRemoteRepo.journeyStream,
      emitsInOrder([
        isNull, // seeded state
        isNotNull,
        isNotNull,
      ]),
    );

    // WHEN
    await sferaRemoteRepo.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 200));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 200));

    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
    mqttSubject.add(jpResponse);

    await Future.delayed(Duration(milliseconds: 200));

    mqttSubject.add(spResponse);
    mqttSubject.add(tcResponse);

    await Future.delayed(Duration(milliseconds: 200));

    final eventMessage = loadFile('test_resources/SFERA_G2B_EventMessage_9315.xml');
    mqttSubject.add(eventMessage);

    await Future.delayed(Duration(milliseconds: 200));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).called(3);
    verify(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).called(3);
  });

  test('should reload SP and TC after new JP', () async {
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
          id: 1,
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
          id: 1,
          tcId: 'T9135',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedTCResponse.payload!.trainCharacteristics.first.toString(),
        ),
      ),
    );

    // LATER THEN
    expectLater(
      sferaRemoteRepo.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .connected,
      ]),
    );
    expectLater(
      sferaRemoteRepo.journeyStream,
      emitsInOrder([
        isNull, // seeded state
        isNotNull,
        isNotNull,
      ]),
    );

    // WHEN
    await sferaRemoteRepo.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 200));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 200));

    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
    mqttSubject.add(jpResponse);

    await Future.delayed(Duration(milliseconds: 200));

    mqttSubject.add(spResponse);
    mqttSubject.add(tcResponse);

    await Future.delayed(Duration(milliseconds: 200));

    final jpEvent = loadFile('test_resources/SFERA_G2B_Event_JP_9315.xml');
    mqttSubject.add(jpEvent);

    await Future.delayed(Duration(milliseconds: 200));

    // THEN
    verify(mockMqttService.connect(any, any)).called(1);
    verify(mockLocalDatabaseRepository.findSegmentProfile(any, any, any)).called(5);
    verify(mockLocalDatabaseRepository.findTrainCharacteristics(any, any, any)).called(5);
  });

  test('should send session termination on disconnect', () async {
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
          id: 1,
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
          id: 1,
          tcId: 'T9135',
          majorVersion: '1',
          minorVersion: '0',
          xmlData: parsedTCResponse.payload!.trainCharacteristics.first.toString(),
        ),
      ),
    );

    // LATER THEN
    expectLater(
      sferaRemoteRepo.stateStream,
      emitsInOrder(<SferaRemoteRepositoryState>[
        .disconnected, // seeded state
        .connecting,
        .connected,
        .disconnected,
      ]),
    );
    expectLater(
      sferaRemoteRepo.journeyStream,
      emitsInOrder([
        isNull, // seeded state
        isNotNull,
        isNotNull,
      ]),
    );

    // WHEN
    await sferaRemoteRepo.connect(trainId);
    // Wait till async tasks are finished
    await Future.delayed(Duration(milliseconds: 200));

    final handshakeResponse = loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml');
    mqttSubject.add(handshakeResponse);

    await Future.delayed(Duration(milliseconds: 200));

    final jpResponse = loadFile('test_resources/SFERA_G2B_Reply_JP_request_9315.xml');
    mqttSubject.add(jpResponse);

    await Future.delayed(Duration(milliseconds: 200));

    mqttSubject.add(spResponse);
    mqttSubject.add(tcResponse);

    await Future.delayed(Duration(milliseconds: 200));

    sferaRemoteRepo.disconnect();

    await Future.delayed(Duration(milliseconds: 200));

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
}
