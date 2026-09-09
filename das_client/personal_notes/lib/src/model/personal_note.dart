class const PersonalNote({
  required final String locationCode,
  required final String text,
  required final bool showAsFootnote,
}) {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PersonalNote &&
            runtimeType == other.runtimeType &&
            locationCode == other.locationCode &&
            text == other.text &&
            showAsFootnote == other.showAsFootnote;
  }

  @override
  int get hashCode => Object.hash(locationCode, text, showAsFootnote);

  @override
  String toString() {
    return 'PersonalNote{locationCode: $locationCode, text: $text, showAsFootnote: $showAsFootnote}';
  }
}
