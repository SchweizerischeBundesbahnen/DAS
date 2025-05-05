import 'package:sfera/src/data/dto/journey_profile.dart';
import 'package:sfera/src/data/dto/network_specific_event.dart';
import 'package:sfera/src/data/dto/related_train_information.dart';
import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class G2bEventPayload extends SferaXmlElement {
  static const String elementType = 'G2B_EventPayload';

  G2bEventPayload({super.type = elementType, super.attributes, super.children, super.value});

  RelatedTrainInformation? get relatedTrainInformation => children.whereType<RelatedTrainInformation>().firstOrNull;

  Iterable<JourneyProfile> get journeyProfiles => children.whereType<JourneyProfile>();

  NetworkSpecificEvent? get networkSpecificEvent => children.whereType<NetworkSpecificEvent>().firstOrNull;
}
