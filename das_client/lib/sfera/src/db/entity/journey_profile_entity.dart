import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/sfera_reply_parser.dart';
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

  JourneyProfile toDomain() {
    return SferaReplyParser.parse<JourneyProfile>(xmlData);
  }
}

extension JourneyProfileMapperX on JourneyProfile {
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
