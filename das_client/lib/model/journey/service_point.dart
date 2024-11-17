import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/localized_string.dart';

class ServicePoint extends BaseData {
  ServicePoint({required this.name, required super.order, required super.kilometre})
      : super(type: Datatype.servicePoint);

  final LocalizedString name;
}
