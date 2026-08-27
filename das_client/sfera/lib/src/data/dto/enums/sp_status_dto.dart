import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum SpStatusDto({@override required final String xmlValue}) implements XmlEnum {
  valid(xmlValue: 'Valid'),
  invalid(xmlValue: 'Invalid');
}
