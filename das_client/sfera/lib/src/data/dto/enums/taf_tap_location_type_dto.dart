import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum TafTapLocationTypeDto implements XmlEnum {
  station(xmlValue: 'station'),
  halt(xmlValue: 'halt')
  ;

  const TafTapLocationTypeDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
