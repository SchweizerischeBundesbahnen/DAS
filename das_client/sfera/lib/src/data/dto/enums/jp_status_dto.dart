import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum JpStatusDto({@override required final String xmlValue}) implements XmlEnum {
  valid(xmlValue: 'Valid'),
  invalid(xmlValue: 'Invalid'),
  unavailable(xmlValue: 'Unavailable'),
  update(xmlValue: 'Update'),
  overwrite(xmlValue: 'Overwrite'),
}
