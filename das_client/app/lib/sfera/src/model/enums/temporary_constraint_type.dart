import 'package:app/sfera/src/model/enums/xml_enum.dart';

enum TemporaryConstraintType implements XmlEnum {
  asr(xmlValue: 'ASR'),
  lowAdhesion(xmlValue: 'Low_Adhesion'),
  tractionTotalCurrent(xmlValue: 'TractionTotalCurrent'),
  regenerationTotalCurrent(xmlValue: 'RegenerationTotalCurrent'),
  powerAdvice(xmlValue: 'PowerAdvice'),
  estimatedVoltage(xmlValue: 'EstimatedVoltage'),
  wind(xmlValue: 'Wind'),
  unavailableDasOperatingModes(xmlValue: 'Unavailable_DAS_OperatingModes'),
  advisedSpeed(xmlValue: 'AdvisedSpeed'),
  networkSpecificConstraint(xmlValue: 'NetworkSpecificConstraint');

  const TemporaryConstraintType({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
