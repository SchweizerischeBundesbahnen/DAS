import 'package:app/pages/journey/journey_screen/header/view_model/model/short_term_change_model.dart';
import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

extension ShortTermChangeIterableX on Iterable<ShortTermChange> {
  ShortTermChange? get getHighestPriority {
    return sorted((a, b) => a.compareByPriority(b)).firstOrNull;
  }
}

extension ShortTermChangeX on ShortTermChange {
  int compareByPriority(ShortTermChange other) {
    int getPriority(ShortTermChange change) {
      return switch (change) {
        PassToStopChange() => 0,
        StopToPassChange() => 1,
        TrainRunReroutingChange() => 2,
        EndDestinationChange() => 3,
      };
    }

    return getPriority(this).compareTo(getPriority(other));
  }

  ShortTermChangeType get toChangeType => switch (this) {
    StopToPassChange() => .stopToPass,
    PassToStopChange() => .passToStop,
    TrainRunReroutingChange() => .trainRunRerouting,
    EndDestinationChange() => .endDestination,
  };
}
