import 'package:app/sfera/src/model/enums/xml_enum.dart';

enum LengthType implements XmlEnum {
  short(xmlValue: 'short'),
  long(xmlValue: 'long');

  const LengthType({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
