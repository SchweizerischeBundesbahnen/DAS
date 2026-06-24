import 'package:app/extension/datetime_extension.dart';
import 'package:app/util/format.dart' show Format;
import 'package:sfera/component.dart';

extension ArrivalDepartureTimeX on ArrivalDepartureTime? {
  (String, String, bool) formattedTimes({
    required bool showOperationalTime,
    required bool showTimesInBrackets,
    DateTime? currentTime,
  }) {
    String departureTime = '';
    String arrivalTime = '';
    if (this == null) return (departureTime, arrivalTime, false);

    if (showOperationalTime) {
      departureTime = Format.operationalTime(this?.operationalDepartureTime);
      arrivalTime = Format.operationalTime(this?.operationalArrivalTime);
    } else {
      departureTime = Format.plannedTime(this?.plannedDepartureTime);
      arrivalTime = Format.plannedTime(this?.plannedArrivalTime);
    }

    var isDepartureUnderlined = currentTime?.isAfterOrSameToTheMinute(this?.plannedDepartureTime) ?? false;

    if (departureTime.isEmpty && this?.plannedReleasedTime != null) {
      departureTime = Format.plannedTime(this?.plannedReleasedTime);

      // plannedReleaseTime is always shown in brackets and never underlined
      showTimesInBrackets = true;
      isDepartureUnderlined = false;
    }

    if (showTimesInBrackets) {
      departureTime = departureTime.isNotEmpty ? '($departureTime)' : departureTime;
      arrivalTime = arrivalTime.isNotEmpty ? '($arrivalTime)' : arrivalTime;
    }

    arrivalTime = arrivalTime.isNotEmpty ? '$arrivalTime\n' : arrivalTime;

    return (departureTime, arrivalTime, isDepartureUnderlined);
  }
}

extension _DateTimeExtension on DateTime {
  bool isAfterOrSameToTheMinute(DateTime? other) {
    if (other == null) return false;
    return roundDownToMinute.isAfterOrSame(other.roundDownToMinute);
  }

  bool isAfterOrSame(DateTime other) => isAtSameMomentAs(other) || isAfter(other);
}
