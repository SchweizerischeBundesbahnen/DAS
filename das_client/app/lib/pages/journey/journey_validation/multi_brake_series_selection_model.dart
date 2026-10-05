import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class MultiBrakeSeriesSelectionModel({
  final List<BrakeSeries> selectedBrakeSeries = const [],
  final Set<BrakeSeries> allowedBrakeSeries = const {},
  final Set<BrakeSeries> availableBrakeSeries = const {},
}) {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            other is MultiBrakeSeriesSelectionModel &&
            ListEquality().equals(selectedBrakeSeries, other.selectedBrakeSeries) &&
            SetEquality().equals(allowedBrakeSeries, other.allowedBrakeSeries) &&
            SetEquality().equals(availableBrakeSeries, other.availableBrakeSeries));
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(selectedBrakeSeries),
    Object.hashAll(allowedBrakeSeries),
    Object.hashAll(availableBrakeSeries),
  );

  @override
  String toString() {
    return 'MultiBrakeSeriesSelectionModel{'
        'selectedBrakeSeries: $selectedBrakeSeries'
        ', allowedBrakeSeries: $allowedBrakeSeries'
        ', availableBrakeSeries: $availableBrakeSeries'
        '}';
  }
}
