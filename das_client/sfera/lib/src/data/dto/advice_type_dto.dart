import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum AdviceTypeDto implements XmlEnum {
  stopAdvice(xmlValue: 'StopAdvice'),
  accelerationAdvice(xmlValue: 'AccelerationAdvice'),
  constantspeedAdvice(xmlValue: 'ConstantspeedAdvice'),
  coastingAdvice(xmlValue: 'CoastingAdvice'),
  operationalBrakingAdvice(xmlValue: 'OperationalBrakingAdvice'),
  electricalBrakingAdvice(xmlValue: 'ElectricalBrakingAdvice'),
  endOfAdvice(xmlValue: 'EndOfAdvice'),
  departureAdvice(xmlValue: 'DepartureAdvice'),
  textAdvice(xmlValue: 'TextAdvice'),
  deleteAdvice(xmlValue: 'DeleteAdvice');

  const AdviceTypeDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
