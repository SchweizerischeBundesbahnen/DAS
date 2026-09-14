class const PersonalNote({
  required final String locationCode,
  required final String text,
  required final bool showAsFootnote,
  required final DateTime lastModifiedAt,
}) {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PersonalNote &&
            runtimeType == other.runtimeType &&
            locationCode == other.locationCode &&
            text == other.text &&
            showAsFootnote == other.showAsFootnote &&
            lastModifiedAt == other.lastModifiedAt;
  }

  @override
  int get hashCode => Object.hash(locationCode, text, showAsFootnote, lastModifiedAt);

  @override
  String toString() {
    return 'PersonalNote{locationCode: $locationCode, text: $text, showAsFootnote: $showAsFootnote, '
        'lastModifiedAt: $lastModifiedAt}';
  }
}
