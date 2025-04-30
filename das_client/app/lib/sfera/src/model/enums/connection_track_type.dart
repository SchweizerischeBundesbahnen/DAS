import 'package:app/sfera/src/model/enums/xml_enum.dart';

enum ConnectionTrackType implements XmlEnum {
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

  const ConnectionTrackType({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
