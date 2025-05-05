import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum SpStatus implements XmlEnum {
  valid(xmlValue: 'Valid'),
  invalid(xmlValue: 'Invalid');

  const SpStatus({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
