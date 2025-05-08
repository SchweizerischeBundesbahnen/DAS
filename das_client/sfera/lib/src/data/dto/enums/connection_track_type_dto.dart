import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum ConnectionTrackTypeDto implements XmlEnum {
  convergenceFromRight(xmlValue: 'ConvergenceFromRight'),
  convergingIntoRight(xmlValue: 'ConvergingIntoRight'),
  convergenceFromLeft(xmlValue: 'ConvergenceFromLeft'),
  convergingIntoLeft(xmlValue: 'ConvergingIntoLeft'),
  crossingFromRightToLeft(xmlValue: 'CrossingFromRightToLeft'),
  crossingFromLeftToRight(xmlValue: 'CrossingFromLeftToRight'),
  crossingALineOnLeft(xmlValue: 'CrossingALineOnLeft'),
  crossingALineOnRight(xmlValue: 'CrossingALineOnRight'),
  divergenceIntoRight(xmlValue: 'DivergenceIntoRight'),
  divergenceAtRight(xmlValue: 'DivergenceAtRight'),
  divergenceIntoLeft(xmlValue: 'DivergenceIntoLeft'),
  divergenceAtLeft(xmlValue: 'DivergenceAtLeft'),
  unknown(xmlValue: 'Unknown');

  const ConnectionTrackTypeDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
