import 'package:sfera/src/model/journey_profile.dart';
import 'package:sfera/src/model/related_train_information.dart';
import 'package:sfera/src/model/segment_profile.dart';
import 'package:sfera/src/model/sfera_xml_element.dart';
import 'package:sfera/src/model/train_characteristics.dart';

class G2bReplyPayload extends SferaXmlElement {
  static const String elementType = 'G2B_ReplyPayload';

  G2bReplyPayload({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<JourneyProfile> get journeyProfiles => children.whereType<JourneyProfile>();

  Iterable<SegmentProfile> get segmentProfiles => children.whereType<SegmentProfile>();

  Iterable<TrainCharacteristics> get trainCharacteristics => children.whereType<TrainCharacteristics>();

  Iterable<RelatedTrainInformation> get relatedTrainInformation => children.whereType<RelatedTrainInformation>();
}
