sealed class const JourneyAdvancementModel() {
  @override
  bool operator ==(Object other) => identical(this, other) || runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  bool get isInManualCycle => switch (this) {
    final Paused p => p.next is Manual,
    Automatic _ => false,
    Manual _ => true,
  };
}

/// When JourneyAdvancement is paused, no automatic scrolling will happen.
///
/// The next determines the model if user toggles modes.
class Paused({required final JourneyAdvancementModel next}) extends JourneyAdvancementModel {
  this : super();

  @override
  String toString() {
    return 'Paused{next: $next}';
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Paused && next == other.next;

  @override
  int get hashCode => next.hashCode;
}

/// When JourneyAdvancement is automatic, the JourneyTable will be scrolled to current position received by
/// TMS VAD after an idle timeout without user interaction has passed.
///
/// The SBBHeaderSmall in the JourneyPage will be hidden.
class const Automatic() extends JourneyAdvancementModel;

/// When JourneyAdvancement is manual, the JourneyTable will be scrolled immediately to user set position and from
/// there on after an idle timeout without user interaction has passed.
///
/// The SBBHeaderSmall in the JourneyPage will be hidden.
class const Manual() extends JourneyAdvancementModel;
