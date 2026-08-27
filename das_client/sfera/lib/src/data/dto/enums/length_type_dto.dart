import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum LengthTypeDto({@override required final String xmlValue}) implements XmlEnum {
  short(xmlValue: 'short'),
  long(xmlValue: 'long');
}
