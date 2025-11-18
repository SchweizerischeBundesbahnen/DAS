import 'package:sfera/component.dart';

class DepartureAuthorizationModel {
  DepartureAuthorizationModel({this.servicePoint});

  final ServicePoint? servicePoint;

  String? get departureAuthText {
    final departureAuthText = servicePoint?.departureAuthorization?.text;
    if (departureAuthText == null) return null;

    return '(${servicePoint!.abbreviation}) $departureAuthText';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepartureAuthorizationModel && runtimeType == other.runtimeType && servicePoint == other.servicePoint;

  @override
  int get hashCode => servicePoint.hashCode;

  @override
  String toString() {
    return 'DepartureAuthorizationModel{servicePoint: $servicePoint, departureAuthText: $departureAuthText}';
  }
}
