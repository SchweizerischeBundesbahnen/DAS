import 'package:das_client/model/sfera/segment_profile.dart';
import 'package:das_client/model/sfera/sfera_reply_parser.dart';
import 'package:isar/isar.dart';

part 'segment_profile_entity.g.dart';

@Collection(accessor: "segmentProfile")
class SegmentProfileEntity {
  SegmentProfileEntity(
      {this.id = Isar.autoIncrement,
      required this.spId,
      required this.majorVersion,
      required this.minorVersion,
      required this.xmlData});

  final Id id;
  final String spId;
  final String majorVersion;
  final String minorVersion;
  final String xmlData;

  SegmentProfile toDomain() {
    return SferaReplyParser.parse<SegmentProfile>(xmlData);
  }
}

extension SegmentProfileMapperX on SegmentProfile {
  SegmentProfileEntity toEntity() {
    return SegmentProfileEntity(
        spId: id, majorVersion: versionMajor, minorVersion: versionMinor, xmlData: buildDocument().toString());
  }
}
