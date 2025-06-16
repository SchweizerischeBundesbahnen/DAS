import 'package:drift/drift.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/local/drift_database_service.dart';
import 'package:sfera/src/data/parser/sfera_reply_parser.dart';

class JourneyProfileTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get company => text()();

  TextColumn get operationalTrainNumber => text()();

  DateTimeColumn get startDate => dateTime()();

  TextColumn get xmlData => text()();
}

extension JourneyProfileMapperX on JourneyProfileDto {
  JourneyProfileTableCompanion toCompanion({int? id, DateTime? startDate}) {
    return JourneyProfileTableCompanion.insert(
      id: id != null ? Value(id) : const Value.absent(),
      company: trainIdentification.otnId.company,
      operationalTrainNumber: trainIdentification.otnId.operationalTrainNumber,
      startDate: trainIdentification.otnId.startDate,
      xmlData: buildDocument().toString(),
    );
  }
}

extension JourneyProfileTableDataX on JourneyProfileTableData {
  JourneyProfileDto toDomain() {
    return SferaReplyParser.parse<JourneyProfileDto>(xmlData);
  }
}
