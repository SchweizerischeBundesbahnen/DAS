import 'package:das_client/sfera/src/model/segment_profile_list.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/train_identification.dart';

class JourneyProfile extends SferaXmlElement {
  static const String elementType = 'JourneyProfile';

  JourneyProfile({super.type = elementType, super.attributes, super.children, super.value});

  TrainIdentification get trainIdentification => children.whereType<TrainIdentification>().first;

  Iterable<SegmentProfileList> get segmentProfilesLists => children.whereType<SegmentProfileList>();

  @override
  bool validate() {
    return validateHasChild('TrainIdentification') && super.validate();
  }
}
