enum TransportPaperLinkType {
  pdfRedirect('PDF_REDIRECT'),
  url('URL'),
  unknown('');

  TransportPaperLinkType(this.value);

  final String value;

  static TransportPaperLinkType fromString(String raw) {
    return TransportPaperLinkType.values.firstWhere((it) => it.value == raw, orElse: () => .unknown);
  }
}
