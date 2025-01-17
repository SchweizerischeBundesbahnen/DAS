import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/related_train_information.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class G2bEventPayload extends SferaXmlElement {
  static const String elementType = 'G2B_EventPayload';

  G2bEventPayload({super.type = elementType, super.attributes, super.children, super.value});

  RelatedTrainInformation? get relatedTrainInformation => children.whereType<RelatedTrainInformation>().firstOrNull;

  Iterable<JourneyProfile> get journeyProfiles => children.whereType<JourneyProfile>();

}
