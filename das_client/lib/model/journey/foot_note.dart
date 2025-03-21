class FootNote {
  FootNote({required this.text, this.type, this.refText});

  final String text;
  final FootNoteType? type;
  final String? refText;
}

enum FootNoteType { trackSpeed, decisiveGradientUp, decisiveGradientDown, contact, networkType, journey }
