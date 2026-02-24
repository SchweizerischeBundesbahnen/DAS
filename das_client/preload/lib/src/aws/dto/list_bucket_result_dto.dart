import 'package:preload/src/aws/dto/contents_dto.dart';
import 'package:xml/xml.dart';

class ListBucketResultDto {
  static const String xmlTag = 'ListBucketResult';

  ListBucketResultDto({required this.xmlElement});

  final XmlElement xmlElement;

  Iterable<ContentsDto> get contents {
    final contentsElements = xmlElement.findElements(ContentsDto.xmlTag);
    return contentsElements.map((e) => ContentsDto(xmlElement: e));
  }

  String get name {
    return xmlElement.getElement('Name')?.innerText ?? '';
  }

  int get keyCount {
    final keyCountText = xmlElement.getElement('KeyCount')?.innerText;
    return keyCountText != null ? int.parse(keyCountText) : 0;
  }

  bool get isTruncated {
    final isTruncatedText = xmlElement.getElement('IsTruncated')?.innerText;
    return isTruncatedText?.toLowerCase() == 'true';
  }

  @override
  String toString() {
    return 'ListBucketResultDto{name: $name, keyCount: $keyCount, isTruncated: $isTruncated, contents: $contents}';
  }
}
