import 'package:isar/isar.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/parser/sfera_reply_parser.dart';

part 'segment_profile_entity.g.dart';

@Collection(accessor: 'segmentProfile')
class SegmentProfileEntity {
  SegmentProfileEntity({
    required this.id,
    required this.spId,
    required this.majorVersion,
    required this.minorVersion,
    required this.xmlData,
  });

  final int id;
  final String spId;
  final String majorVersion;
  final String minorVersion;
  final String xmlData;

  SegmentProfileDto toDomain() {
    return SferaReplyParser.parse<SegmentProfileDto>(xmlData);
  }
}

extension SegmentProfileMapperX on SegmentProfileDto {
  SegmentProfileEntity toEntity({required int isarId}) {
    return SegmentProfileEntity(
      id: isarId,
      spId: this.id,
      majorVersion: versionMajor,
      minorVersion: versionMinor,
      xmlData: buildDocument().toString(),
    );
  }
}
