import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum DasArchitectureDto implements XmlEnum {
  groundAdviceCalculation(xmlValue: 'GroundAdviceCalculation'),
  boardAdviceCalculation(xmlValue: 'BoardAdviceCalculation');

  const DasArchitectureDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
