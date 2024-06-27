import 'package:das_client/model/sfera/segment_profile_list.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';

class JourneyProfile extends SferaXmlElement {
  static const String elementType = "JourneyProfile";

  JourneyProfile({required super.type, super.attributes, super.children, super.value});

  SferaXmlElement get trainIdentification => childrenWithType("TrainIdentification").first;

  Iterable<SegmentProfileList> get segmentProfilesLists => children.whereType<SegmentProfileList>();

  @override
  bool validate() {
    return validateHasChild("TrainIdentification") && super.validate();
  }
}
