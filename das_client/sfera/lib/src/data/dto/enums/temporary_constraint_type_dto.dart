import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum TemporaryConstraintTypeDto({@override required final String xmlValue}) implements XmlEnum {
  asr(xmlValue: 'ASR'),
  lowAdhesion(xmlValue: 'Low_Adhesion'),
  tractionTotalCurrent(xmlValue: 'TractionTotalCurrent'),
  regenerationTotalCurrent(xmlValue: 'RegenerationTotalCurrent'),
  powerAdvice(xmlValue: 'PowerAdvice'),
  estimatedVoltage(xmlValue: 'EstimatedVoltage'),
  wind(xmlValue: 'Wind'),
  unavailableDasOperatingModes(xmlValue: 'Unavailable_DAS_OperatingModes'),
  advisedSpeed(xmlValue: 'AdvisedSpeed'),
  networkSpecificConstraint(xmlValue: 'NetworkSpecificConstraint'),
}
