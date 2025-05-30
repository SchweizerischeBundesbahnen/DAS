import 'package:isar/isar.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/parser/sfera_reply_parser.dart';

part 'train_characteristics_entity.g.dart';

@Collection(accessor: 'trainCharacteristics')
class TrainCharacteristicsEntity {
  TrainCharacteristicsEntity({
    required this.id,
    required this.tcId,
    required this.majorVersion,
    required this.minorVersion,
    required this.xmlData,
  });

  final int id;
  final String tcId;
  final String majorVersion;
  final String minorVersion;
  final String xmlData;

  TrainCharacteristicsDto toDomain() {
    return SferaReplyParser.parse<TrainCharacteristicsDto>(xmlData);
  }
}

extension TrainCharacteristicsMapperX on TrainCharacteristicsDto {
  TrainCharacteristicsEntity toEntity({required int isarId}) {
    return TrainCharacteristicsEntity(
      id: isarId,
      tcId: tcId,
      majorVersion: versionMajor,
      minorVersion: versionMinor,
      xmlData: buildDocument().toString(),
    );
  }
}
