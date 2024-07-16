import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/segment_profile.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';

class G2bReplyPayload extends SferaXmlElement {
  static const String elementType = "G2B_ReplyPayload";

  G2bReplyPayload({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<JourneyProfile> get journeyProfiles => children.whereType<JourneyProfile>();

  Iterable<SegmentProfile> get segmentProfiles => children.whereType<SegmentProfile>();
}
