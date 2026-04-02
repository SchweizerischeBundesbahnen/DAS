// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/local/drift_sfera_local_database_service.dart';
import 'package:sfera/src/data/parser/sfera_reply_parser.dart';

class JourneyProfileTable extends Table {
  TextColumn get version => text()();

  TextColumn get company => text()();

  TextColumn get operationalTrainNumber => text()();

  DateTimeColumn get startDate => dateTime()();

  TextColumn get xmlData => text()();

  @override
  Set<Column<Object>>? get primaryKey => {company, operationalTrainNumber, startDate, version};
}

extension JourneyProfileMapperX on JourneyProfileDto {
  JourneyProfileTableCompanion toCompanion() {
    return JourneyProfileTableCompanion.insert(
      version: version,
      company: trainIdentification.otnId.company,
      operationalTrainNumber: trainIdentification.otnId.operationalTrainNumber,
      startDate: trainIdentification.otnId.startDate,
      xmlData: buildDocument().toString(),
    );
  }
}

extension JourneyProfileTableDataX on JourneyProfileTableData {
  JourneyProfileDto toDomain() => SferaReplyParser.parse<JourneyProfileDto>(xmlData);
}
