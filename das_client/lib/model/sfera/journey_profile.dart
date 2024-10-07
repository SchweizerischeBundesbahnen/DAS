import 'package:das_client/model/sfera/segment_profile_list.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/model/sfera/train_identification.dart';

class JourneyProfile extends SferaXmlElement {
  static const String elementType = "JourneyProfile";

  JourneyProfile({super.type = elementType, super.attributes, super.children, super.value});

  TrainIdentification get trainIdentification => children.whereType<TrainIdentification>().first;

  Iterable<SegmentProfileList> get segmentProfilesLists => children.whereType<SegmentProfileList>();

  @override
  bool validate() {
    return validateHasChild("TrainIdentification") && super.validate();
  }
}
