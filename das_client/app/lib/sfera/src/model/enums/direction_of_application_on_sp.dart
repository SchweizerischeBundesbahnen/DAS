import 'package:app/sfera/src/model/enums/xml_enum.dart';

enum DirectionOfApplicationOnSP implements XmlEnum {
  nominal(xmlValue: 'Nominal'),
  reverse(xmlValue: 'Reverse'),
  both(xmlValue: 'Both');

  const DirectionOfApplicationOnSP({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
