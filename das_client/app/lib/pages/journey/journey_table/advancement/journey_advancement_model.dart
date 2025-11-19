sealed class JourneyAdvancementModel {
  const JourneyAdvancementModel();
}

/// When JourneyAdvancement is paused, no automatic scrolling will happen.
///
/// The SBBHeader in the JourneyPage will be displayed.
class Paused extends JourneyAdvancementModel {}

/// When JourneyAdvancement is automatic, the JourneyTable will be scrolled to current position received by
/// TMS VAD after an idle timeout without user interaction has passed.
///
/// The SBBHeader in the JourneyPage will be hidden.
class Automatic extends JourneyAdvancementModel {
  const Automatic();
}

/// When JourneyAdvancement is manual, the JourneyTable will be scrolled immediately to user set position and from
/// there on after an idle timeout without user interaction has passed.
///
/// The SBBHeader in the JourneyPage will be hidden.
class Manual extends JourneyAdvancementModel {}
