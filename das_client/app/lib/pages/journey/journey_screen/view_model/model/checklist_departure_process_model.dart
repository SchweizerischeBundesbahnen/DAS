import 'package:customer_oriented_departure/component.dart';
import 'package:sfera/component.dart';

sealed class ChecklistDepartureProcessModel {
  const ChecklistDepartureProcessModel._();

  ServicePoint? get nextStop => switch (this) {
    ChecklistDepartureProcessDisabled() => null,
    NoCustomerOrientedDepartureChecklist(nextStop: final stop) => stop,
    CustomerOrientedDepartureChecklist(nextStop: final stop) => stop,
  };
}

class ChecklistDepartureProcessDisabled extends ChecklistDepartureProcessModel {
  const ChecklistDepartureProcessDisabled() : super._();

  @override
  bool operator ==(Object other) => other is ChecklistDepartureProcessDisabled;

  @override
  int get hashCode => runtimeType.hashCode;
}

class NoCustomerOrientedDepartureChecklist extends ChecklistDepartureProcessModel {
  const NoCustomerOrientedDepartureChecklist({required this.nextStop}) : super._();

  @override
  final ServicePoint? nextStop;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NoCustomerOrientedDepartureChecklist && nextStop == other.nextStop;

  @override
  int get hashCode => nextStop.hashCode;
}

class CustomerOrientedDepartureChecklist extends ChecklistDepartureProcessModel {
  const CustomerOrientedDepartureChecklist({required this.nextStop, required this.customerOrientedDepartureStatus})
    : super._();

  @override
  final ServicePoint? nextStop;
  final CustomerOrientedDepartureStatus customerOrientedDepartureStatus;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerOrientedDepartureChecklist &&
          nextStop == other.nextStop &&
          customerOrientedDepartureStatus == other.customerOrientedDepartureStatus;

  @override
  int get hashCode => Object.hash(nextStop, customerOrientedDepartureStatus);
}
