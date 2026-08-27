import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum ConnectionTrackTypeDto({@override required final String xmlValue}) implements XmlEnum {
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
}
