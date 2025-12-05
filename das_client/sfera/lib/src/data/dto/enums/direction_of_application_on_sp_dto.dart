import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum DirectionOfApplicationOnSPDto implements XmlEnum {
  nominal(xmlValue: 'Nominal'),
  reverse(xmlValue: 'Reverse'),
  both(xmlValue: 'Both')
  ;

  const DirectionOfApplicationOnSPDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
