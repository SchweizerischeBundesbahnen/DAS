import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum RouteTableDataRelevantDto implements XmlEnum {
  isTrue(xmlValue: 'true'),
  isFalse(xmlValue: 'false'),
  unlisted(xmlValue: 'unlisted')
  ;

  const RouteTableDataRelevantDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
