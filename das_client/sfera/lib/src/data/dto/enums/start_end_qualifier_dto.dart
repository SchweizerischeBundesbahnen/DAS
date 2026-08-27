import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum StartEndQualifierDto({@override required final String xmlValue}) implements XmlEnum {
  starts(xmlValue: 'Starts'),
  ends(xmlValue: 'Ends'),
  startsEnds(xmlValue: 'StartsEnds'),
  wholeSp(xmlValue: 'WholeSP');
}
