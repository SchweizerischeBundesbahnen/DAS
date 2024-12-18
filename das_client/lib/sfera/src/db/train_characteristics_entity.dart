import 'package:das_client/sfera/src/model/train_characteristics.dart';
import 'package:das_client/sfera/src/sfera_reply_parser.dart';
import 'package:isar/isar.dart';

part 'train_characteristics_entity.g.dart';

@Collection(accessor: 'trainCharacteristics')
class TrainCharacteristicsEntity {
  TrainCharacteristicsEntity(
      {required this.id,
      required this.tcId,
      required this.majorVersion,
      required this.minorVersion,
      required this.xmlData});

  final int id;
  final String tcId;
  final String majorVersion;
  final String minorVersion;
  final String xmlData;

  TrainCharacteristics toDomain() {
    return SferaReplyParser.parse<TrainCharacteristics>(xmlData);
  }
}

extension TrainCharacteristicsMapperX on TrainCharacteristics {
  TrainCharacteristicsEntity toEntity({required int isarId}) {
    return TrainCharacteristicsEntity(
        id: isarId,
        tcId: tcId,
        majorVersion: versionMajor,
        minorVersion: versionMinor,
        xmlData: buildDocument().toString());
  }
}
