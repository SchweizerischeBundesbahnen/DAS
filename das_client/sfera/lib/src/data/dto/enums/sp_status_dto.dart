import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum SpStatusDto implements XmlEnum {
  valid(xmlValue: 'Valid'),
  invalid(xmlValue: 'Invalid')
  ;

  const SpStatusDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
