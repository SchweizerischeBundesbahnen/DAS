class RuIndicationContent {
  const RuIndicationContent({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  String toString() {
    return 'RuIndicationContent{title: $title, text: $text}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuIndicationContent && runtimeType == other.runtimeType && title == other.title && text == other.text;

  @override
  int get hashCode => Object.hash(title, text);
}
