typedef StartEndInt = ({int? start, int? end});

/// compares two ranges with start and end int
class StartEndIntComparator {
  StartEndIntComparator._();

  static int compare(StartEndInt a, StartEndInt b) {
    // START TO START comparison
    if (a.start != null && b.start != null) {
      final startComparison = a.start!.compareTo(b.start!);
      if (startComparison != 0) {
        return startComparison;
      }
    }
    // if start is null, it is considered outside of range and smaller
    if (a.start == null && b.start != null) return -1;
    if (a.start != null && b.start == null) return 1;

    // END_TO_END comparison
    if (a.end != null && b.end != null) return a.end!.compareTo(b.end!);

    // if end is null, it is considered outside of range and bigger
    if (a.end == null && b.end != null) return 1;
    if (a.end != null && b.end == null) return -1;

    // at this point, both ends are null, starts are equal or both null
    // then ranges are equal
    return 0;
  }
}
