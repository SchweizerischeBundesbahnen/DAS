import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/mapper/sfera_reply_parser.dart';
import 'package:isar/isar.dart';

part 'journey_profile_entity.g.dart';

@Collection(accessor: 'journeyProfile')
class JourneyProfileEntity {
  JourneyProfileEntity({
    required this.id,
    required this.company,
    required this.operationalTrainNumber,
    required this.startDate,
    required this.xmlData,
  });

  @Id()
  final int id;
  final String company;
  final String operationalTrainNumber;
  final DateTime startDate;
  final String xmlData;

  JourneyProfileDto toDomain() {
    return SferaReplyParser.parse<JourneyProfileDto>(xmlData);
  }
}

extension JourneyProfileMapperX on JourneyProfileDto {
  JourneyProfileEntity toEntity({required int id, DateTime? startDate}) {
    return JourneyProfileEntity(
      id: id,
      company: trainIdentification.otnId.company,
      operationalTrainNumber: trainIdentification.otnId.operationalTrainNumber,
      startDate: startDate ?? trainIdentification.otnId.startDate,
      // Temporary fix, because our backend does not return correct date in Journey Profile
      xmlData: buildDocument().toString(),
    );
  }
}
