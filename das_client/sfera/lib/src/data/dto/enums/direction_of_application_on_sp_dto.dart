import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum DirectionOfApplicationOnSPDto({@override required final String xmlValue}) implements XmlEnum {
  nominal(xmlValue: 'Nominal'),
  reverse(xmlValue: 'Reverse'),
  both(xmlValue: 'Both');
}
