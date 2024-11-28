import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/track_equipment.dart';

abstract class BaseData {
  BaseData({
    required this.type,
    required this.order,
    required this.kilometre,
    this.trackEquipment = const [],
  });

  final Datatype type;
  final int order;
  final List<double> kilometre;
  final List<TrackEquipment> trackEquipment;
}
