typedef StartEndInt = ({int? start, int? end});

/// compares two ranges with start and end int
class StartEndIntComparator {
  StartEndIntComparator._();

  static int compare(StartEndInt a, StartEndInt b) {
    if (a.start != null && b.start != null) {
      final startComparison = a.start!.compareTo(b.start!);
      if (startComparison != 0) {
        return startComparison;
      }
    }

    // if start is null, it is considered outside of range and smaller
    if (a.start == null && b.start != null) {
      return -1;
    } else if (a.start != null && b.start == null) {
      return 1;
    }

    // if starts are not given, compare ends
    // if end is null, it is considered outside of range and bigger
    if (a.end != null && b.end != null) {
      return a.end!.compareTo(b.end!);
    } else if (a.end == null) {
      return 1;
    } else if (b.end == null) {
      return -1;
    }

    return 0;
  }
}
