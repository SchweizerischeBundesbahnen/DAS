import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/api/task/request_local_regulations_task.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/local/drift_sfera_local_database_service.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/model/otn_id.dart';

import 'sfera_request_local_regulations_task_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SferaRepository>(),
  MockSpec<MqttService>(),
  MockSpec<SferaLocalDatabaseService>(),
])
void main() {
  late MockSferaRepository mockSferaRepo;
  late MockMqttService mqttService;
  late MockSferaLocalDatabaseService sferaLocalService;
  late OtnId otnId;

  String loadFile(String path) => File(path).readAsStringSync();

  ServicePoint buildServicePoint({List<String> localRegulationSegmentIds = const []}) => ServicePoint(
    name: 'Test SP',
    abbreviation: 'TSP',
    locationCode: '8500000',
    order: 1000,
    kilometre: const [0.0],
    localRegulationSegmentIds: localRegulationSegmentIds,
  );

  setUp(() {
    mockSferaRepo = MockSferaRepository();
    when(mockSferaRepo.messageHeader(sender: anyNamed('sender'))).thenReturn(MessageHeaderDto());
    mqttService = MockMqttService();
    sferaLocalService = MockSferaLocalDatabaseService();
    otnId = OtnId(company: '1085', operationalTrainNumber: '719', startDate: DateTime.now());
  });

  test('execute_whenLocalRegulationsAreMissing_thenRequestsSegmentProfilesWithLocalizedUniqueIds', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);
    when(sferaLocalService.findSegmentProfile(any, any, any)).thenAnswer((_) async => null);

    final servicePoints = <ServicePoint>[
      buildServicePoint(localRegulationSegmentIds: ['RL_701', 'RL_702']),
      buildServicePoint(localRegulationSegmentIds: ['RL_702', 'RL_703']),
    ];

    final localRegulationsTask = RequestLocalRegulationsTask(
      mqttService: mqttService,
      sferaRepo: mockSferaRepo,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      servicePoints: servicePoints,
    );

    await localRegulationsTask.execute(
      (_, __) {},
      (task, error) => fail('Task failed with error $error'),
    );

    verify(sferaLocalService.findSegmentProfile('RL_701_DE', '0', '')).called(1);
    verify(sferaLocalService.findSegmentProfile('RL_702_DE', '0', '')).called(1);
    verify(sferaLocalService.findSegmentProfile('RL_703_DE', '0', '')).called(1);

    final publishedXml = verify(mqttService.publishMessage(any, any, captureAny)).captured.single as String;
    expect(publishedXml, contains('<SP_Request'));
    expect(publishedXml, contains('SP_ID="RL_701_DE"'));
    expect(publishedXml, contains('SP_ID="RL_702_DE"'));
    expect(publishedXml, contains('SP_ID="RL_703_DE"'));
    expect(publishedXml, contains('SP_VersionMajor="0"'));
    expect(publishedXml, contains('SP_VersionMinor=""'));
  });

  test('execute_whenNoLocalRegulationsAreMissing_thenCompletesWithoutRequestingSegmentProfiles', () async {
    when(sferaLocalService.findSegmentProfile(any, any, any)).thenAnswer(
      (_) async => SegmentProfileTableData(
        spId: 'RL_701_DE',
        majorVersion: '0',
        minorVersion: '',
        xmlData: '<SegmentProfile/>',
      ),
    );

    final servicePoints = <ServicePoint>[
      buildServicePoint(localRegulationSegmentIds: ['RL_701']),
    ];

    var taskCompleted = false;
    final localRegulationsTask = RequestLocalRegulationsTask(
      mqttService: mqttService,
      sferaRepo: mockSferaRepo,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      servicePoints: servicePoints,
    );
    await localRegulationsTask.execute(
      (task, data) {
        taskCompleted = true;
        expect(task, localRegulationsTask);
      },
      (task, error) => fail('Task failed with error $error'),
    );

    expect(taskCompleted, true);
    verifyNever(mqttService.publishMessage(any, any, any));
  });

  test('handleMessage_whenReceivingSegmentProfiles_thenSavesValidProfilesAndCompletes', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);
    when(sferaLocalService.findSegmentProfile(any, any, any)).thenAnswer((_) async => null);

    final reply = SferaReplyParser.parse<SferaG2bReplyMessageDto>(
      loadFile('test_resources/SFERA_G2B_Reply_JP_request_9232_invalid_sp.xml'),
    );

    var completedCount = 0;
    final localRegulationsTask = RequestLocalRegulationsTask(
      mqttService: mqttService,
      sferaRepo: mockSferaRepo,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      servicePoints: [
        buildServicePoint(localRegulationSegmentIds: ['RL_701']),
      ],
    );

    await localRegulationsTask.execute(
      (task, _) {
        completedCount++;
        expect(task, localRegulationsTask);
      },
      (task, error) => fail('Task failed with error $error'),
    );

    final result = await localRegulationsTask.handleMessage(reply);

    expect(result, true);
    expect(completedCount, greaterThanOrEqualTo(1));
    verify(sferaLocalService.saveSegmentProfile(any)).called(1);
  });

  test('handleMessage_whenReceivingOtherReply_thenIgnoresIt', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);
    when(sferaLocalService.findSegmentProfile(any, any, any)).thenAnswer((_) async => null);

    final localRegulationsTask = RequestLocalRegulationsTask(
      mqttService: mqttService,
      sferaRepo: mockSferaRepo,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      servicePoints: [
        buildServicePoint(localRegulationSegmentIds: ['RL_701']),
      ],
    );

    await localRegulationsTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) => fail('Test should not call error'),
    );

    final reply = SferaReplyParser.parse<SferaG2bReplyMessageDto>(
      loadFile('test_resources/SFERA_G2B_ReplyMessage_handshake.xml'),
    );

    final result = await localRegulationsTask.handleMessage(reply);

    expect(result, false);
    verify(mqttService.publishMessage(any, any, any)).called(1);
  });

  test('execute_whenRequestLocalRegulationsTimesOut_thenFailsWithRequestTimeout', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);
    when(sferaLocalService.findSegmentProfile(any, any, any)).thenAnswer((_) async => null);

    var timeoutReached = false;

    final localRegulationsTask = RequestLocalRegulationsTask(
      mqttService: mqttService,
      sferaRepo: mockSferaRepo,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      servicePoints: [
        buildServicePoint(localRegulationSegmentIds: ['RL_701']),
      ],
      timeout: const Duration(seconds: 1),
    );

    await localRegulationsTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) {
        expect(error, isA<RequestTimeout>());
        timeoutReached = true;
      },
    );

    verify(mqttService.publishMessage(any, any, any)).called(1);

    await Future.delayed(const Duration(milliseconds: 1200));

    expect(timeoutReached, true);
  });

  test('handleMessage_whenReceivingProtocolError_thenFailsWithProtocolErrors', () async {
    when(mqttService.publishMessage(any, any, any)).thenReturn(true);
    when(sferaLocalService.findSegmentProfile(any, any, any)).thenAnswer((_) async => null);

    final localRegulationsTask = RequestLocalRegulationsTask(
      mqttService: mqttService,
      sferaRepo: mockSferaRepo,
      sferaDatabaseRepository: sferaLocalService,
      otnId: otnId,
      servicePoints: [
        buildServicePoint(localRegulationSegmentIds: ['RL_701']),
      ],
    );

    await localRegulationsTask.execute(
      (task, data) => fail('Test should not call success'),
      (task, error) {
        expect(error, isA<ProtocolErrors>());
        final protocolError = error as ProtocolErrors;
        expect(protocolError.errors, hasLength(1));
        expect(protocolError.errors.first.code, '26');
      },
    );

    final reply = SferaReplyParser.parse<SferaG2bReplyMessageDto>(
      loadFile('test_resources/SFERA_G2B_ReplyMessage_Error.xml'),
    );

    final result = await localRegulationsTask.handleMessage(reply);

    expect(result, false);
  });
}
