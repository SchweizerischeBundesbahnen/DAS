import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum TafTapLocationTypeDto({@override required final String xmlValue}) implements XmlEnum {
  station(xmlValue: 'station'),
  halt(xmlValue: 'halt');
}
