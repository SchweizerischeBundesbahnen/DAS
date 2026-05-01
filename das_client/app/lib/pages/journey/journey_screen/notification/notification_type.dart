// MUST be ordered according to priority - see https://github.com/SchweizerischeBundesbahnen/DAS/issues/1402
enum NotificationType {
  reauthenticationRequired,
  illegalSegmentNoReplacement,
  koaWait,
  koaWaitCancelled,
  newBrakeLoadSlip,
  maneuverMode,
  disturbance,
  advisedSpeed,
  departureDispatch,
  illegalSegmentWithReplacement,
  suspiciousSegment,
}
