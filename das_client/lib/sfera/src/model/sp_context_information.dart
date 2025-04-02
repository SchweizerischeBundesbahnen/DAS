import 'package:das_client/sfera/src/model/communication_network.dart';
import 'package:das_client/sfera/src/model/connection_track.dart';
import 'package:das_client/sfera/src/model/contact_list.dart';
import 'package:das_client/sfera/src/model/kilometre_reference_point.dart';
import 'package:das_client/sfera/src/model/level_crossing_area.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class SpContextInformation extends SferaXmlElement {
  static const String elementType = 'SP_ContextInformation';

  SpContextInformation({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<KilometreReferencePoint> get kilometreReferencePoints => children.whereType<KilometreReferencePoint>();

  Iterable<ConnectionTrack> get connectionTracks => children.whereType<ConnectionTrack>();

  Iterable<CommunicationNetwork> get communicationNetworks => children.whereType<CommunicationNetwork>();

  Iterable<LevelCrossingArea> get levelCrossings => children.whereType<LevelCrossingArea>();

  Iterable<SferaContactList> get contactLists => children.whereType<SferaContactList>();
}
