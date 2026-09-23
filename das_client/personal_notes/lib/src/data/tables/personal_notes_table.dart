// coverage:ignore-file

import 'package:core_data/component.dart';
import 'package:drift/drift.dart';
import 'package:personal_notes/component.dart';
import 'package:personal_notes/src/data/drift_personal_notes_database_service.dart';

class PersonalNotesTable extends Table {
  TextColumn get locationCode => text()();

  TextColumn get trainCompanyCode => text().nullable()();

  TextColumn get trainNumber => text().nullable()();

  DateTimeColumn get trainDate => dateTime().nullable()();

  DateTimeColumn get trainOperatingDay => dateTime().nullable()();

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
      trainCompanyCode: Value(trainIdentification?.companyCode),
      trainNumber: Value(trainIdentification?.trainNumber),
      trainDate: Value(trainIdentification?.date),
      trainOperatingDay: Value(trainIdentification?.operatingDay),
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
    if (trainNumber == null || trainNumber == null || trainDate == null) return null;

    return TrainIdentification(
      companyCode: trainCompanyCode!,
      trainNumber: trainNumber!,
      date: trainDate!,
      operatingDay: trainOperatingDay,
    );
  }
}
