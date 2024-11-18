import 'package:das_client/sfera/src/model/enums/xml_enum.dart';

enum TafTapLocationType implements XmlEnum {
  station(xmlValue: 'station'),
  stoppingLocation(xmlValue: 'stopping location');

  const TafTapLocationType({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
