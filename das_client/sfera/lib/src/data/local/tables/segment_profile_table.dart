// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/local/drift_local_database_service.dart';
import 'package:sfera/src/data/parser/sfera_reply_parser.dart';

class SegmentProfileTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get spId => text()();

  TextColumn get majorVersion => text()();

  TextColumn get minorVersion => text()();

  TextColumn get xmlData => text()();
}

extension SegmentProfileMapperX on SegmentProfileDto {
  SegmentProfileTableCompanion toCompanion() {
    return SegmentProfileTableCompanion.insert(
      spId: id,
      majorVersion: versionMajor,
      minorVersion: versionMinor,
      xmlData: buildDocument().toString(),
    );
  }
}

extension SegmentProfileTableDataX on SegmentProfileTableData {
  SegmentProfileDto toDomain() {
    return SferaReplyParser.parse<SegmentProfileDto>(xmlData);
  }
}
