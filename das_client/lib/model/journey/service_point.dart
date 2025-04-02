import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/bracket_station.dart';
import 'package:das_client/model/journey/contact_list.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/speed_data.dart';
import 'package:das_client/model/localized_string.dart';

class ServicePoint extends BaseData {
  const ServicePoint({
    required this.name,
    required super.order,
    required super.kilometre,
    super.speedData,
    super.localSpeedData,
    this.mandatoryStop = false,
    this.isStop = false,
    this.isStation = false,
    this.bracketMainStation,
    this.graduatedSpeedInfo,
    this.contactList,
  }) : super(type: Datatype.servicePoint);

  final LocalizedString name;
  final bool mandatoryStop;
  final bool isStop;
  final bool isStation;
  final BracketMainStation? bracketMainStation;
  final SpeedData? graduatedSpeedInfo;
  final ContactList? contactList;

  @override
  String toString() {
    return 'ServicePoint(order: $order, kilometre: $kilometre, name: $name, mandatoryStop: $mandatoryStop, isStop: $isStop, isStation: $isStation, bracketMainStation: $bracketMainStation, speedData: $speedData, localSpeedData: $localSpeedData, contactList: $contactList)';
  }
}
