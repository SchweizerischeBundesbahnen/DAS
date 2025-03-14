import 'package:das_client/sfera/src/model/enums/xml_enum.dart';

enum StopSkipPass implements XmlEnum {
  stoppingPoint(xmlValue: 'Stopping_Point'),
  skippedStoppingPoint(xmlValue: 'Skipped_Stopping_Point'),
  passingPoint(xmlValue: 'Passing_Point');

  const StopSkipPass({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
