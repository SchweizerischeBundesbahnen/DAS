import 'package:das_client/sfera/src/model/enums/xml_enum.dart';

enum RelatedTrainRequestType implements XmlEnum {
  none(xmlValue: 'None'),
  ownTrain(xmlValue: 'OwnTrain'),
  relatedTrains(xmlValue: 'RelatedTrains'),
  ownTrainAndRelatedTrains(xmlValue: 'OwnTrainAndRelatedTrains'),
  ownTrainAndOrRelatedTrains(xmlValue: 'OwnTrainAndOrRelatedTrains');

  const RelatedTrainRequestType({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
