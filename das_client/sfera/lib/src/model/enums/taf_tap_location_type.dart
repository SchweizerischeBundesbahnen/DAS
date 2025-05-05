import 'package:sfera/src/model/enums/xml_enum.dart';

enum TafTapLocationType implements XmlEnum {
  station(xmlValue: 'station'),
  halt(xmlValue: 'halt');

  const TafTapLocationType({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
