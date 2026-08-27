import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum DasArchitectureDto({@override required final String xmlValue}) implements XmlEnum {
  groundAdviceCalculation(xmlValue: 'GroundAdviceCalculation'),
  boardAdviceCalculation(xmlValue: 'BoardAdviceCalculation');
}
