import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum RelatedTrainRequestTypeDto implements XmlEnum {
  none(xmlValue: 'None'),
  ownTrain(xmlValue: 'OwnTrain'),
  relatedTrains(xmlValue: 'RelatedTrains'),
  ownTrainAndRelatedTrains(xmlValue: 'OwnTrainAndRelatedTrains'),
  ownTrainAndOrRelatedTrains(xmlValue: 'OwnTrainAndOrRelatedTrains')
  ;

  const RelatedTrainRequestTypeDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
