import 'package:app/extension/datetime_extension.dart';
import 'package:app/util/format.dart' show Format;
import 'package:sfera/component.dart';

class FormattedArrivalDepartureTimes {
  const FormattedArrivalDepartureTimes({
    required this.departureTime,
    required this.arrivalTime,
    required this.isDepartureUnderlined,
    required this.isDepartureBold,
  });

  final String departureTime;
  final String arrivalTime;
  final bool isDepartureUnderlined;
  final bool isDepartureBold;
}

extension ArrivalDepartureTimeX on ArrivalDepartureTime? {
  FormattedArrivalDepartureTimes formattedTimes({
    required bool showOperationalTime,
    required bool showTimesInBrackets,
    DateTime? currentTime,
  }) {
    String departureTime = '';
    String arrivalTime = '';
    bool isDepartureBold = true;
    if (this == null) {
      return FormattedArrivalDepartureTimes(
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        isDepartureUnderlined: false,
        isDepartureBold: isDepartureBold,
      );
    }

    if (showOperationalTime) {
      departureTime = Format.operationalTime(this?.operationalDepartureTime);
      arrivalTime = Format.operationalTime(this?.operationalArrivalTime);
    } else {
      departureTime = Format.plannedTime(this?.plannedDepartureTime);
      arrivalTime = Format.plannedTime(this?.plannedArrivalTime);
    }

    var isDepartureUnderlined = currentTime?.isAfterOrSameToTheMinute(this?.plannedDepartureTime) ?? false;

    if (departureTime.isEmpty && this?.plannedReleasedTime != null) {
      if (showOperationalTime) {
        departureTime = Format.operationalTime(this?.plannedReleasedTime);
      } else {
        departureTime = Format.plannedTime(this?.plannedReleasedTime);
      }

      // plannedReleaseTime is always shown in brackets and never underlined and never bold
      showTimesInBrackets = true;
      isDepartureUnderlined = false;
      isDepartureBold = false;
    }

    if (showTimesInBrackets) {
      departureTime = departureTime.isNotEmpty ? '($departureTime)' : departureTime;
      arrivalTime = arrivalTime.isNotEmpty ? '($arrivalTime)' : arrivalTime;
    }

    arrivalTime = arrivalTime.isNotEmpty ? '$arrivalTime\n' : arrivalTime;

    return FormattedArrivalDepartureTimes(
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      isDepartureUnderlined: isDepartureUnderlined,
      isDepartureBold: isDepartureBold,
    );
  }
}

extension _DateTimeExtension on DateTime {
  bool isAfterOrSameToTheMinute(DateTime? other) {
    if (other == null) return false;
    return roundDownToMinute.isAfterOrSame(other.roundDownToMinute);
  }

  bool isAfterOrSame(DateTime other) => isAtSameMomentAs(other) || isAfter(other);
}
