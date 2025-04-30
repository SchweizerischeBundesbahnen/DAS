import 'package:app/sfera/src/model/enums/jp_status.dart';
import 'package:app/sfera/src/model/enums/xml_enum.dart';
import 'package:app/sfera/src/model/segment_profile_list.dart';
import 'package:app/sfera/src/model/sfera_xml_element.dart';
import 'package:app/sfera/src/model/train_characteristics_ref.dart';
import 'package:app/sfera/src/model/train_identification.dart';

class JourneyProfile extends SferaXmlElement {
  static const String elementType = 'JourneyProfile';

  JourneyProfile({super.type = elementType, super.attributes, super.children, super.value});

  TrainIdentification get trainIdentification => children.whereType<TrainIdentification>().first;

  Iterable<SegmentProfileReference> get segmentProfileReferences => children.whereType<SegmentProfileReference>();

  Set<TrainCharacteristicsRef> get trainCharacteristicsRefSet =>
      children.whereType<SegmentProfileReference>().map((it) => it.trainCharacteristicsRef).expand((it) => it).toSet();

  JpStatus get status => XmlEnum.valueOf<JpStatus>(JpStatus.values, attributes['JP_Status']) ?? JpStatus.valid;

  @override
  bool validate() {
    return validateHasChildOfType<TrainIdentification>() && super.validate();
  }
}
