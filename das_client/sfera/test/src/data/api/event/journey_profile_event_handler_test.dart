import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/src/data/api/event/journey_profile_event_handler.dart';
import 'package:sfera/src/data/api/event/sfera_event_message_handler.dart';
import 'package:sfera/src/data/dto/enums/jp_status_dto.dart';
import 'package:sfera/src/data/dto/g2b_event_payload_dto.dart';
import 'package:sfera/src/data/dto/general_jp_information_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/otn_id_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_list_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_event_message_dto.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';

import 'journey_profile_event_handler_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SferaLocalDatabaseService>(),
])
void main() {
  late MockSferaLocalDatabaseService mockDatabaseService;
  late List<JourneyProfileDto> handledProfiles;
  late List<SferaEventMessageHandler> handledHandlers;
  JourneyProfileDto? currentJourneyProfile;

  setUp(() {
    mockDatabaseService = MockSferaLocalDatabaseService();
    handledProfiles = [];
    handledHandlers = [];
    currentJourneyProfile = null;
  });

  JourneyProfileEventHandler createEventHandler() {
    return JourneyProfileEventHandler(
      (handler, data) {
        handledHandlers.add(handler);
        handledProfiles.add(data);
      },
      mockDatabaseService,
      () => currentJourneyProfile,
    );
  }

  group('handleMessage', () {
    test('handleMessage_whenPayloadIsNull_thenReturnsFalse', () async {
      // GIVEN
      final eventHandler = createEventHandler();
      final eventMessage = _createEventMessage(hasPayload: false);

      // WHEN
      final result = await eventHandler.handleMessage(eventMessage);

      // THEN
      expect(result, isFalse);
      verifyZeroInteractions(mockDatabaseService);
      expect(handledProfiles, isEmpty);
      expect(handledHandlers, isEmpty);
    });

    test('handleMessage_whenJourneyProfilesIsEmpty_thenReturnsFalse', () async {
      // GIVEN
      final eventHandler = createEventHandler();
      final eventMessage = _createEventMessage(journeyProfiles: []);

      // WHEN
      final result = await eventHandler.handleMessage(eventMessage);

      // THEN
      expect(result, isFalse);
      verifyZeroInteractions(mockDatabaseService);
      expect(handledProfiles, isEmpty);
      expect(handledHandlers, isEmpty);
    });

    test('handleMessage_whenStatusIsInvalid_thenReturnsTrueWithoutSaving', () async {
      // GIVEN
      final eventHandler = createEventHandler();
      final profile = _createJourneyProfile(status: JpStatusDto.invalid);
      final eventMessage = _createEventMessage(journeyProfiles: [profile]);

      // WHEN
      final result = await eventHandler.handleMessage(eventMessage);

      // THEN
      expect(result, isTrue);
      verifyZeroInteractions(mockDatabaseService);
      expect(handledProfiles, isEmpty);
      expect(handledHandlers, isEmpty);
    });

    test('handleMessage_whenStatusIsUnavailable_thenReturnsTrueWithoutSaving', () async {
      // GIVEN
      final eventHandler = createEventHandler();
      final profile = _createJourneyProfile(status: JpStatusDto.unavailable);
      final eventMessage = _createEventMessage(journeyProfiles: [profile]);

      // WHEN
      final result = await eventHandler.handleMessage(eventMessage);

      // THEN
      expect(result, isTrue);
      verifyZeroInteractions(mockDatabaseService);
      expect(handledProfiles, isEmpty);
      expect(handledHandlers, isEmpty);
    });

    test('handleMessage_whenStatusIsValid_thenSavesJourneyProfileAndCallsOnMessageHandled', () async {
      // GIVEN
      final eventHandler = createEventHandler();
      final profile = _createJourneyProfile(status: JpStatusDto.valid);
      final eventMessage = _createEventMessage(journeyProfiles: [profile]);

      // WHEN
      final result = await eventHandler.handleMessage(eventMessage);

      // THEN
      expect(result, isTrue);
      verify(mockDatabaseService.saveJourneyProfile(profile)).called(1);
      expect(handledProfiles, [profile]);
      expect(handledHandlers, [eventHandler]);
    });

    test('handleMessage_whenStatusIsOverwrite_thenSavesJourneyProfileAndCallsOnMessageHandled', () async {
      // GIVEN
      final eventHandler = createEventHandler();
      final profile = _createJourneyProfile(status: JpStatusDto.overwrite);
      final eventMessage = _createEventMessage(journeyProfiles: [profile]);

      // WHEN
      final result = await eventHandler.handleMessage(eventMessage);

      // THEN
      expect(result, isTrue);
      verify(mockDatabaseService.saveJourneyProfile(profile)).called(1);
      expect(handledProfiles, [profile]);
      expect(handledHandlers, [eventHandler]);
    });

    test('handleMessage_whenStatusIsUpdateAndNoCurrentJourneyProfile_thenReturnsFalse', () async {
      // GIVEN
      currentJourneyProfile = null;
      final eventHandler = createEventHandler();
      final profile = _createJourneyProfile(status: JpStatusDto.update);
      final eventMessage = _createEventMessage(journeyProfiles: [profile]);

      // WHEN
      final result = await eventHandler.handleMessage(eventMessage);

      // THEN
      expect(result, isFalse);
      verifyZeroInteractions(mockDatabaseService);
      expect(handledProfiles, isEmpty);
      expect(handledHandlers, isEmpty);
    });

    test('handleMessage_whenStatusIsUpdateAndCurrentProfileExists_thenMergesSavesAndCallsOnMessageHandled', () async {
      // GIVEN
      final seg1 = _createSegmentProfileReference(spId: 'SP1', versionMajor: '1', versionMinor: '0');
      final seg2 = _createSegmentProfileReference(spId: 'SP2', versionMajor: '1', versionMinor: '0');
      final seg3 = _createSegmentProfileReference(spId: 'SP3', versionMajor: '1', versionMinor: '0');
      final seg4 = _createSegmentProfileReference(spId: 'SP4', versionMajor: '1', versionMinor: '0');
      currentJourneyProfile = _createJourneyProfile(
        version: '1',
        segmentProfileReferences: [seg1, seg2, seg3],
      );

      final eventHandler = createEventHandler();
      final updatedProfile = _createJourneyProfile(
        version: '2',
        status: JpStatusDto.update,
        segmentProfileReferences: [seg2, seg4],
      );
      final eventMessage = _createEventMessage(journeyProfiles: [updatedProfile]);

      // WHEN
      final result = await eventHandler.handleMessage(eventMessage);

      // THEN
      expect(result, isTrue);
      final captured = verify(mockDatabaseService.saveJourneyProfile(captureAny)).captured.single as JourneyProfileDto;
      expect(captured.version, '2');
      expect(
        captured.segmentProfileReferences.map((it) => it.spId).toList(),
        ['SP1', 'SP2', 'SP4'],
      );
      expect(handledProfiles, [captured]);
      expect(handledHandlers, [eventHandler]);
    });

    test('handleMessage_whenMoreThanOneJourneyProfileReceived_thenUsesFirstOne', () async {
      // GIVEN
      final eventHandler = createEventHandler();
      final profile1 = _createJourneyProfile(version: '1', status: JpStatusDto.valid);
      final profile2 = _createJourneyProfile(version: '2', status: JpStatusDto.valid);
      final eventMessage = _createEventMessage(journeyProfiles: [profile1, profile2]);

      // WHEN
      final result = await eventHandler.handleMessage(eventMessage);

      // THEN
      expect(result, isTrue);
      verify(mockDatabaseService.saveJourneyProfile(profile1)).called(1);
      verifyNever(mockDatabaseService.saveJourneyProfile(profile2));
      expect(handledProfiles, [profile1]);
      expect(handledHandlers, [eventHandler]);
    });
  });
}

SegmentProfileReferenceDto _createSegmentProfileReference({
  required String spId,
  required String versionMajor,
  String versionMinor = '0',
}) {
  final dto = SegmentProfileReferenceDto();
  dto.attributes['SP_ID'] = spId;
  dto.attributes['SP_VersionMajor'] = versionMajor;
  dto.attributes['SP_VersionMinor'] = versionMinor;
  return dto;
}

JourneyProfileDto _createJourneyProfile({
  String version = '1',
  JpStatusDto status = JpStatusDto.valid,
  List<SegmentProfileReferenceDto> segmentProfileReferences = const [],
  TrainIdentificationDto? trainIdentification,
  GeneralJpInformationDto? generalJpInformation,
}) {
  final dto = JourneyProfileDto();
  dto.attributes['JP_Version'] = version;
  dto.attributes['JP_Status'] = status.xmlValue;
  dto.children.add(
    trainIdentification ??
        TrainIdentificationDto.create(
          otnId: OtnIdDto.create('1085', '719', DateTime(2026, 9, 7)),
        ),
  );
  dto.children.addAll(segmentProfileReferences);
  if (generalJpInformation != null) {
    dto.children.add(generalJpInformation);
  }
  return dto;
}

SferaG2bEventMessageDto _createEventMessage({
  List<JourneyProfileDto>? journeyProfiles,
  bool hasPayload = true,
}) {
  final message = SferaG2bEventMessageDto();
  if (hasPayload) {
    final payload = G2bEventPayloadDto();
    if (journeyProfiles != null) {
      payload.children.addAll(journeyProfiles);
    }
    message.children.add(payload);
  }
  return message;
}
