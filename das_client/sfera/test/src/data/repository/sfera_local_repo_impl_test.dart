import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/otn_id_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_list_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_ref_dto.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';
import 'package:sfera/src/data/local/drift_local_database_service.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/repository/sfera_local_repo_impl.dart';

import 'sfera_local_repo_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SferaLocalDatabaseService>(),
])
void main() {
  late SferaLocalRepo testee;
  late MockSferaLocalDatabaseService mockLocalDatabaseRepository;

  setUp(() {
    mockLocalDatabaseRepository = MockSferaLocalDatabaseService();
    testee = SferaLocalRepoImpl(
      localService: mockLocalDatabaseRepository,
    );
  });

  test('test local database is beeing observed', () async {
    final company = '1085';
    final trainNumber = '719';
    final startDate = DateTime.now();
    final journeyProfile = JourneyProfileDto(
      children: [TrainIdentificationDto.create(otnId: OtnIdDto.create(company, trainNumber, startDate))],
    );

    final subject = BehaviorSubject<JourneyProfileTableData>();

    when(
      mockLocalDatabaseRepository.observeJourneyProfile(any, any, any),
    ).thenAnswer((_) => subject.stream);

    final subscription = testee
        .journeyStream(company: company, trainNumber: trainNumber, startDate: startDate)
        .listen(
          expectAsync1((journey) {
            expect(journey, isNotNull);
          }),
        );

    subject.add(
      JourneyProfileTableData(
        id: 1,
        company: company,
        operationalTrainNumber: trainNumber,
        startDate: startDate,
        xmlData: journeyProfile.toString(),
      ),
    );

    await Future.delayed(Duration(milliseconds: 100));

    verify(mockLocalDatabaseRepository.observeJourneyProfile(any, any, any)).called(1);

    subscription.cancel();
  });

  test('test segment profiles are being resolved', () async {
    final company = '1085';
    final trainNumber = '719';
    final startDate = DateTime.now();

    final spId = 'sp123';
    final majorVersion = '1';
    final minorVersion = '0';

    final journeyProfile = JourneyProfileDto(
      children: [
        TrainIdentificationDto.create(otnId: OtnIdDto.create(company, trainNumber, startDate)),
        SegmentProfileReferenceDto(
          attributes: {
            'SP_ID': spId,
            'SP_VersionMajor': majorVersion,
            'SP_VersionMinor': minorVersion,
          },
        ),
      ],
    );
    final segmentProfile = SegmentProfileTableData(
      id: 1,
      spId: spId,
      majorVersion: majorVersion,
      minorVersion: minorVersion,
      xmlData: SegmentProfileDto().toString(),
    );

    final subject = BehaviorSubject<JourneyProfileTableData>();

    when(
      mockLocalDatabaseRepository.observeJourneyProfile(any, any, any),
    ).thenAnswer((_) => subject.stream);
    when(
      mockLocalDatabaseRepository.findSegmentProfile(spId, majorVersion, minorVersion),
    ).thenAnswer((_) => Future.value(segmentProfile));

    final subscription = testee
        .journeyStream(company: company, trainNumber: trainNumber, startDate: startDate)
        .listen(
          expectAsync1((journey) {
            expect(journey, isNotNull);
          }),
        );

    subject.add(
      JourneyProfileTableData(
        id: 1,
        company: company,
        operationalTrainNumber: trainNumber,
        startDate: startDate,
        xmlData: journeyProfile.toString(),
      ),
    );

    await Future.delayed(Duration(milliseconds: 100));

    verify(mockLocalDatabaseRepository.observeJourneyProfile(any, any, any)).called(1);
    verify(mockLocalDatabaseRepository.findSegmentProfile(spId, majorVersion, minorVersion)).called(1);

    subscription.cancel();
  });

  test('test train characteristics are being resolved', () async {
    final company = '1085';
    final trainNumber = '719';
    final startDate = DateTime.now();

    final spId = 'sp123';
    final tcId = 'tc123';
    final majorVersion = '1';
    final minorVersion = '0';

    final journeyProfile = JourneyProfileDto(
      children: [
        TrainIdentificationDto.create(otnId: OtnIdDto.create(company, trainNumber, startDate)),
        SegmentProfileReferenceDto(
          attributes: {
            'SP_ID': spId,
            'SP_VersionMajor': majorVersion,
            'SP_VersionMinor': minorVersion,
          },
          children: [
            TrainCharacteristicsRefDto(
              attributes: {
                'TC_ID': tcId,
                'TC_VersionMajor': majorVersion,
                'TC_VersionMinor': minorVersion,
              },
              children: [
                SferaXmlElementDto(type: 'TC_RU_ID', value: 'RU123'),
              ],
            ),
          ],
        ),
      ],
    );

    final segmentProfile = SegmentProfileTableData(
      id: 1,
      spId: spId,
      majorVersion: majorVersion,
      minorVersion: minorVersion,
      xmlData: SegmentProfileDto().toString(),
    );

    final trainCharacteristics = TrainCharacteristicsTableData(
      id: 1,
      tcId: spId,
      majorVersion: majorVersion,
      minorVersion: minorVersion,
      xmlData: TrainCharacteristicsDto().toString(),
    );

    final subject = BehaviorSubject<JourneyProfileTableData>();

    when(
      mockLocalDatabaseRepository.observeJourneyProfile(any, any, any),
    ).thenAnswer((_) => subject.stream);
    when(
      mockLocalDatabaseRepository.findSegmentProfile(spId, majorVersion, minorVersion),
    ).thenAnswer((_) => Future.value(segmentProfile));
    when(
      mockLocalDatabaseRepository.findTrainCharacteristics(tcId, majorVersion, minorVersion),
    ).thenAnswer((_) => Future.value(trainCharacteristics));

    final subscription = testee
        .journeyStream(company: company, trainNumber: trainNumber, startDate: startDate)
        .listen(
          expectAsync1((journey) {
            expect(journey, isNotNull);
          }),
        );

    subject.add(
      JourneyProfileTableData(
        id: 1,
        company: company,
        operationalTrainNumber: trainNumber,
        startDate: startDate,
        xmlData: journeyProfile.toString(),
      ),
    );

    await Future.delayed(Duration(milliseconds: 100));

    verify(mockLocalDatabaseRepository.observeJourneyProfile(any, any, any)).called(1);
    verify(mockLocalDatabaseRepository.findSegmentProfile(spId, majorVersion, minorVersion)).called(1);
    verify(mockLocalDatabaseRepository.findTrainCharacteristics(tcId, majorVersion, minorVersion)).called(1);

    subscription.cancel();
  });
}
