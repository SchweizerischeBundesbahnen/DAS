import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/service_point.dart';

class Metadata {
  const Metadata({this.nextStop, this.currentPosition});

  final ServicePoint? nextStop;
  final BaseData? currentPosition;
}
