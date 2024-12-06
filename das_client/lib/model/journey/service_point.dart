import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/bracket_station.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/localized_string.dart';

class ServicePoint extends BaseData {
  ServicePoint({
    required this.name,
    required this.mandatoryStop,
    required this.isStop,
    required this.isStation,
    required super.order,
    required super.kilometre,
    this.bracketStation,
  }) : super(type: Datatype.servicePoint);

  final LocalizedString name;
  final bool mandatoryStop;
  final bool isStop;
  final bool isStation;
  final BracketStation? bracketStation;

  @override
  String toString() {
    return 'ServicePoint(order: $order, kilometre: $kilometre, name: $name, mandatoryStop: $mandatoryStop, isStop: $isStop, isStation: $isStation, bracketStation: $bracketStation)';
  }
}
