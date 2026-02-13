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
        Pass2StopChange() => 0,
        Stop2PassChange() => 1,
        TrainRunReroutingChange() => 2,
        EndDestinationChange() => 3,
      };
    }

    return getPriority(this).compareTo(getPriority(other));
  }
}
