/// Responsible for the advancement of the JourneyTable.
///
/// The advancement can be either:
/// * paused (no automatic scrolling will happen)
/// * auto (scrolling happens after idle time)
/// * manual (user set position on journey - will scroll once to the new position)
class JourneyAdvancementViewModel {
  void pauseAutomaticAdvancement() {}

  void startAutomaticAdvancement() {}
}
