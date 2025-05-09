import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum DasConnectivityDto implements XmlEnum {
  standalone(xmlValue: 'Standalone'),
  connected(xmlValue: 'Connected');

  const DasConnectivityDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
