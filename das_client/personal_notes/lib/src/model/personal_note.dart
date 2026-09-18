import 'package:core_data/component.dart';

class PersonalNote({
  required final String locationCode,
  required final String text,
  required final bool showAsFootnote,
  final TrainIdentification? trainIdentification,
  DateTime? lastModifiedAt,
}) {
  this : lastModifiedAt = lastModifiedAt ?? DateTime.now();

  final DateTime lastModifiedAt;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PersonalNote &&
            runtimeType == other.runtimeType &&
            locationCode == other.locationCode &&
            text == other.text &&
            showAsFootnote == other.showAsFootnote &&
            trainIdentification == other.trainIdentification &&
            lastModifiedAt == other.lastModifiedAt;
  }

  @override
  int get hashCode => Object.hash(locationCode, text, showAsFootnote, lastModifiedAt, trainIdentification);

  @override
  String toString() {
    return 'PersonalNote{'
        'locationCode: $locationCode, '
        'text: $text, '
        'showAsFootnote: $showAsFootnote, '
        'trainIdentification: $trainIdentification, '
        'lastModifiedAt: $lastModifiedAt'
        '}';
  }
}
