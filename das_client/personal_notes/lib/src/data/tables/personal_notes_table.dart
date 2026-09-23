// coverage:ignore-file

import 'package:core_data/component.dart';
import 'package:drift/drift.dart';
import 'package:personal_notes/component.dart';
import 'package:personal_notes/src/data/drift_personal_notes_database_service.dart';

final sentinelDate = DateTime.fromMillisecondsSinceEpoch(0);

/// Note: NULL values are not considered equal in SQLite.
/// For this reason, all columns relevant for the primary key have default values.
class PersonalNotesTable extends Table {
  TextColumn get locationCode => text()();

  TextColumn get trainCompanyCode => text().withDefault(const Constant(''))();

  TextColumn get trainNumber => text().withDefault(const Constant(''))();

  DateTimeColumn get trainDate => dateTime().withDefault(Constant(sentinelDate))();

  DateTimeColumn get trainOperatingDay => dateTime().withDefault(Constant(sentinelDate))();

  TextColumn get noteText => text()();

  BoolColumn get showAsFootnote => boolean()();

  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get lastModifiedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {locationCode, trainCompanyCode, trainNumber, trainDate, trainOperatingDay};
}

extension PersonalNoteMapperX on PersonalNote {
  PersonalNotesTableCompanion toCompanion() {
    return PersonalNotesTableCompanion.insert(
      locationCode: locationCode,
      trainCompanyCode: Value(trainIdentification?.companyCode ?? ''),
      trainNumber: Value(trainIdentification?.trainNumber ?? ''),
      trainDate: Value(trainIdentification?.date ?? sentinelDate),
      trainOperatingDay: Value(trainIdentification?.operatingDay ?? sentinelDate),
      noteText: text,
      showAsFootnote: showAsFootnote,
      deleted: Value(deleted),
      lastModifiedAt: lastModifiedAt,
    );
  }
}

extension PersonalNotesTableDataX on PersonalNotesTableData {
  PersonalNote toDomain() {
    return PersonalNote(
      locationCode: locationCode,
      text: noteText,
      showAsFootnote: showAsFootnote,
      trainIdentification: _toTrainIdentification(),
      deleted: deleted,
      lastModifiedAt: lastModifiedAt,
    );
  }

  TrainIdentification? _toTrainIdentification() {
    if (trainNumber.isEmpty || trainNumber.isEmpty || trainDate == sentinelDate) return null;

    return TrainIdentification(
      companyCode: trainCompanyCode,
      trainNumber: trainNumber,
      date: trainDate,
      operatingDay: trainOperatingDay == sentinelDate ? null : trainOperatingDay,
    );
  }
}
