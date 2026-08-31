enum TransportPaperLinkType(final String value) {
  pdfRedirect('PDF_REDIRECT'),
  url('URL'),
  unknown('');

  static TransportPaperLinkType fromString(String raw) {
    return TransportPaperLinkType.values.firstWhere((it) => it.value == raw, orElse: () => .unknown);
  }
}
