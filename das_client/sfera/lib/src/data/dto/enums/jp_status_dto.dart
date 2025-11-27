import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum JpStatusDto implements XmlEnum {
  valid(xmlValue: 'Valid'),
  invalid(xmlValue: 'Invalid'),
  unavailable(xmlValue: 'Unavailable'),
  update(xmlValue: 'Update'),
  overwrite(xmlValue: 'Overwrite')
  ;

  const JpStatusDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
