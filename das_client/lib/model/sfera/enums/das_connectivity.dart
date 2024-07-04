import 'package:das_client/model/sfera/enums/xml_enum.dart';

enum DasConnectivity implements XmlEnum {
  standalone(xmlValue: "Standalone"),
  connected(xmlValue: "Connected");

  const DasConnectivity({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
