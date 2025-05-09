import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum LengthTypeDto implements XmlEnum {
  short(xmlValue: 'short'),
  long(xmlValue: 'long');

  const LengthTypeDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
