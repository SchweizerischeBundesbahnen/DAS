import 'package:core_data/component.dart';

class PersonalNote({
  required final String locationCode,
  required final String text,
  required final bool showAsFootnote,
  final TrainIdentification? trainIdentification,
  final bool deleted = false,
  DateTime? lastModifiedAt,
}) {
  this : lastModifiedAt = lastModifiedAt ?? DateTime.now();

  final DateTime lastModifiedAt;

  /// Whether the note should be synchronized with the backend.
  ///
  /// Note: Single use notes are not synchronized as there is not need for a backup.
  bool get shouldBeSynchronized => trainIdentification == null;

  PersonalNote copyWith({
    String? locationCode,
    String? text,
    bool? showAsFootnote,
    TrainIdentification? trainIdentification,
    bool? deleted,
    DateTime? lastModifiedAt,
  }) {
    return PersonalNote(
      locationCode: locationCode ?? this.locationCode,
      text: text ?? this.text,
      showAsFootnote: showAsFootnote ?? this.showAsFootnote,
      trainIdentification: trainIdentification ?? this.trainIdentification,
      deleted: deleted ?? this.deleted,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PersonalNote &&
            runtimeType == other.runtimeType &&
            locationCode == other.locationCode &&
            text == other.text &&
            showAsFootnote == other.showAsFootnote &&
            trainIdentification == other.trainIdentification &&
            deleted == other.deleted &&
            lastModifiedAt == other.lastModifiedAt;
  }

  @override
  int get hashCode => Object.hash(locationCode, text, showAsFootnote, trainIdentification, deleted, lastModifiedAt);

  @override
  String toString() {
    return 'PersonalNote{'
        'locationCode: $locationCode, '
        'text: $text, '
        'showAsFootnote: $showAsFootnote, '
        'trainIdentification: $trainIdentification, '
        'deleted: $deleted, '
        'lastModifiedAt: $lastModifiedAt'
        '}';
  }
}
