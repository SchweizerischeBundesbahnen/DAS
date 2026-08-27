import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum RouteTableDataRelevantDto({@override required final String xmlValue}) implements XmlEnum {
  isTrue(xmlValue: 'true'),
  isFalse(xmlValue: 'false'),
  unlisted(xmlValue: 'unlisted');
}
