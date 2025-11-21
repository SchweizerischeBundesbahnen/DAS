enum ShowSpeedBehavior {
  // Always display speed specified for the position
  always,
  // Always display speed specified for the position, or previous if none is defined
  alwaysOrPrevious,
  // Always display speed specified for the position, or previous if none is defined when the row is sticky / first row
  alwaysOrPreviousOnStickiness,
  // Never display the speed
  never,
}
