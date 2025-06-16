import 'package:drift/drift.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/local/drift_database_service.dart';
import 'package:sfera/src/data/parser/sfera_reply_parser.dart';

class TrainCharacteristicsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get tcId => text()();

  TextColumn get majorVersion => text()();

  TextColumn get minorVersion => text()();

  TextColumn get xmlData => text()();
}

extension TrainCharacteristicsMapperX on TrainCharacteristicsDto {
  TrainCharacteristicsTableCompanion toCompanion() {
    return TrainCharacteristicsTableCompanion.insert(
      tcId: tcId,
      majorVersion: versionMajor,
      minorVersion: versionMinor,
      xmlData: buildDocument().toString(),
    );
  }
}

extension TrainCharacteristicsTableDataX on TrainCharacteristicsTableData {
  TrainCharacteristicsDto toDomain() {
    return SferaReplyParser.parse<TrainCharacteristicsDto>(xmlData);
  }
}
