import 'package:sfera/src/data/dto/communication_network.dart';
import 'package:sfera/src/data/dto/connection_track.dart';
import 'package:sfera/src/data/dto/contact_list.dart';
import 'package:sfera/src/data/dto/decisive_gradient_area.dart';
import 'package:sfera/src/data/dto/kilometre_reference_point.dart';
import 'package:sfera/src/data/dto/level_crossing_area.dart';
import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class SpContextInformation extends SferaXmlElement {
  static const String elementType = 'SP_ContextInformation';

  SpContextInformation({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<KilometreReferencePoint> get kilometreReferencePoints => children.whereType<KilometreReferencePoint>();

  Iterable<ConnectionTrack> get connectionTracks => children.whereType<ConnectionTrack>();

  Iterable<CommunicationNetwork> get communicationNetworks => children.whereType<CommunicationNetwork>();

  Iterable<LevelCrossingArea> get levelCrossings => children.whereType<LevelCrossingArea>();

  Iterable<ContactList> get contactLists => children.whereType<ContactList>();

  Iterable<DecisiveGradientArea> get decisiveGradientAreas => children.whereType<DecisiveGradientArea>();
}
