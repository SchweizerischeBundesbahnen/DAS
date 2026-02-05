import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

extension ShortTermChangeIterableX on Iterable<ShortTermChange> {
  ShortTermChange? get getHighestPriority {
    int getPriority(ShortTermChange change) {
      return switch (change) {
        Pass2StopChange() => 0,
        Stop2PassChange() => 1,
        TrainRunReroutingChange() => 2,
        EndDestinationChange() => 3,
      };
    }

    return sortedBy((change) => getPriority(change)).firstOrNull;
  }
}
