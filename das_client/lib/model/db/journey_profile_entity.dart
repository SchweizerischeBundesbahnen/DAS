import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/sfera_reply_parser.dart';
import 'package:isar/isar.dart';

part 'journey_profile_entity.g.dart';

@Collection(accessor: "journeyProfile")
class JourneyProfileEntity {
  JourneyProfileEntity(
      {this.id = Isar.autoIncrement,
      required this.company,
      required this.operationalTrainNumber,
      required this.startDate,
      required this.xmlData});

  final Id id;
  final String company;
  final String operationalTrainNumber;
  final DateTime startDate;
  final String xmlData;

  JourneyProfile toDomain() {
    return SferaReplyParser.parse<JourneyProfile>(xmlData);
  }
}

extension JourneyProfileMapperX on JourneyProfile {
  JourneyProfileEntity toEntity({Id? id, DateTime? startDate}) {
    return JourneyProfileEntity(
      id: id ?? Isar.autoIncrement,
      company: trainIdentification.otnId.company,
      operationalTrainNumber: trainIdentification.otnId.operationalTrainNumber,
      startDate: startDate ?? trainIdentification.otnId.startDate, // Temporary fix, because our backend does not return correct date in Journey Profile
      xmlData: buildDocument().toString(),
    );
  }
}
