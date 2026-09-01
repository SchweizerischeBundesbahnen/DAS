import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum RelatedTrainRequestTypeDto({@override required final String xmlValue}) implements XmlEnum {
  none(xmlValue: 'None'),
  ownTrain(xmlValue: 'OwnTrain'),
  relatedTrains(xmlValue: 'RelatedTrains'),
  ownTrainAndRelatedTrains(xmlValue: 'OwnTrainAndRelatedTrains'),
  ownTrainAndOrRelatedTrains(xmlValue: 'OwnTrainAndOrRelatedTrains'),
}
