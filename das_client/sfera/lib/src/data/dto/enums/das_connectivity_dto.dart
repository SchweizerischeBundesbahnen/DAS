import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum DasConnectivityDto({@override required final String xmlValue}) implements XmlEnum {
  standalone(xmlValue: 'Standalone'),
  connected(xmlValue: 'Connected');
}
