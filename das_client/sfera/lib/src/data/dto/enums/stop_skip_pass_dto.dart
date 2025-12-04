import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum StopSkipPassDto implements XmlEnum {
  stoppingPoint(xmlValue: 'Stopping_Point'),
  skippedStoppingPoint(xmlValue: 'Skipped_Stopping_Point'),
  passingPoint(xmlValue: 'Passing_Point')
  ;

  const StopSkipPassDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
