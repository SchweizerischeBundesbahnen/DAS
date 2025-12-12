class DepartureDispatchNotificationEvent {
  const DepartureDispatchNotificationEvent({required this.type});

  final DepartureDispatchNotificationType type;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepartureDispatchNotificationEvent && runtimeType == other.runtimeType && type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() {
    return 'DepartureDispatchNotificationEvent{type: $type}';
  }
}

enum DepartureDispatchNotificationType {
  /// departure in >30min
  prepareForDepartureLong,

  /// departure in 15-30min
  prepareForDepartureMiddle,

  /// departure in < 15min
  prepareForDepartureShort,

  /// prepare for departure
  prepareForDeparture,

  /// departure provision withdrawn
  departureProvisionWithdrawn,
}
