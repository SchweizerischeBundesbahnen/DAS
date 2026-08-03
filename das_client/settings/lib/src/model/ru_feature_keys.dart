enum RuFeatureKeys {
  warnapp('WARNAPP'),
  customerOrientedDeparture('CUSTOMER_ORIENTED_DEPARTURE_PROCESS'),
  departureProcess('CHECKLIST_DEPARTURE_PROCESS'),
  plannedTimeDeviation('DISPLAY_PLANNED_TIME_DEVIATION');

  const RuFeatureKeys(this.key);

  final String key;
}
