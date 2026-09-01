import 'package:customer_oriented_departure/component.dart';
import 'package:sfera/component.dart';

sealed class const ChecklistDepartureProcessModel._() {
  ServicePoint? get nextStop => switch (this) {
    ChecklistDepartureProcessDisabled() => null,
    NoCustomerOrientedDepartureChecklist(nextStop: final stop) => stop,
    CustomerOrientedDepartureChecklist(nextStop: final stop) => stop,
  };
}

class const ChecklistDepartureProcessDisabled() extends ChecklistDepartureProcessModel {
  this : super._();

  @override
  bool operator ==(Object other) => other is ChecklistDepartureProcessDisabled;

  @override
  int get hashCode => runtimeType.hashCode;
}

class const NoCustomerOrientedDepartureChecklist({@override required final ServicePoint? nextStop})
    extends ChecklistDepartureProcessModel {
  this : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NoCustomerOrientedDepartureChecklist && nextStop == other.nextStop;

  @override
  int get hashCode => nextStop.hashCode;
}

class const CustomerOrientedDepartureChecklist({
  @override required final ServicePoint? nextStop,
  required final CustomerOrientedDepartureStatus customerOrientedDepartureStatus,
}) extends ChecklistDepartureProcessModel {
  this : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerOrientedDepartureChecklist &&
          nextStop == other.nextStop &&
          customerOrientedDepartureStatus == other.customerOrientedDepartureStatus;

  @override
  int get hashCode => Object.hash(nextStop, customerOrientedDepartureStatus);
}
