enum OrderPriority {
  shuntingMovementStart,
  cabSignalingStart,
  group,
  balise,
  trainDriverTurnoverStart,

  // https://github.com/SchweizerischeBundesbahnen/DAS/issues/2145
  // Do no insert anything between servicePoint & operationalIndication & footNotes
  servicePoint,
  operationalIndication,
  lineFootNotes,
  opFootNote,

  // Make formatter happy :)
  signal,
  baseData,
  trainDriverTurnoverEnd,
  curve,
  trackFootNote,
  cabSignalingEnd,
  shuntingMovementEnd,
}
