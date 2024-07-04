import 'package:das_client/model/sfera/enums/xml_enum.dart';

enum DASArchitecture implements XmlEnum {
  groundAdviceCalculation(xmlValue: "GroundAdviceCalculation"),
  boardAdviceCalculation(xmlValue: "BoardAdviceCalculation");

  const DASArchitecture({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
