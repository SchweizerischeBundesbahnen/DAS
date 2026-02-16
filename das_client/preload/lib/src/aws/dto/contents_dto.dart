import 'package:xml/xml.dart';

class ContentsDto {
  static const String xmlTag = 'Contents';

  ContentsDto({required this.xmlElement});

  final XmlElement xmlElement;

  String get key {
    return xmlElement.getElement('Key')?.innerText ?? '';
  }

  String get eTag {
    return xmlElement.getElement('ETag')?.innerText ?? '';
  }

  int get size {
    final sizeText = xmlElement.getElement('Size')?.innerText;
    return sizeText != null ? int.parse(sizeText) : 0;
  }

  @override
  String toString() {
    return 'ContentsDto{key: $key, eTag: $eTag, size: $size}';
  }
}
