import 'package:sfera/component.dart';

sealed class ChecklistDepartureProcessModel {
  const ChecklistDepartureProcessModel._();
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

  final ServicePoint? nextStop;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NoCustomerOrientedDepartureChecklist && nextStop == other.nextStop;

  @override
  int get hashCode => nextStop.hashCode;
}

class CustomerOrientedDepartureChecklist extends ChecklistDepartureProcessModel {
  const CustomerOrientedDepartureChecklist({required this.nextStop, required this.koaState}) : super._();

  final ServicePoint? nextStop;
  final KoaState koaState;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerOrientedDepartureChecklist && nextStop == other.nextStop && koaState == other.koaState;

  @override
  int get hashCode => Object.hash(nextStop, koaState);
}
