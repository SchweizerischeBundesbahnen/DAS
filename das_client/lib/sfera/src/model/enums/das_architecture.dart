import 'package:das_client/sfera/src/model/enums/xml_enum.dart';

enum DasArchitecture implements XmlEnum {
  groundAdviceCalculation(xmlValue: 'GroundAdviceCalculation'),
  boardAdviceCalculation(xmlValue: 'BoardAdviceCalculation');

  const DasArchitecture({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
