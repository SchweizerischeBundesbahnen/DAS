import 'package:xml/xml.dart';

class ContentsDto({required final XmlElement xmlElement}) {
  static const String xmlTag = 'Contents';

  String get key => xmlElement.getElement('Key')?.innerText ?? '';

  String get eTag => xmlElement.getElement('ETag')?.innerText ?? '';

  int get size {
    final sizeText = xmlElement.getElement('Size')?.innerText;
    return sizeText != null ? int.parse(sizeText) : 0;
  }

  @override
  String toString() {
    return 'ContentsDto{key: $key, eTag: $eTag, size: $size}';
  }
}
