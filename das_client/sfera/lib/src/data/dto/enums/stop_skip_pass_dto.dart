import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum StopSkipPassDto({@override required final String xmlValue}) implements XmlEnum {
  stoppingPoint(xmlValue: 'Stopping_Point'),
  skippedStoppingPoint(xmlValue: 'Skipped_Stopping_Point'),
  passingPoint(xmlValue: 'Passing_Point');
}
