import 'package:sfera/component.dart';

class JourneyNavigationModel {
  JourneyNavigationModel({
    required this.trainIdentification,
    required this.currentIndex,
    required this.navigationStackLength,
  });

  final TrainIdentification trainIdentification;
  final int currentIndex;
  final int navigationStackLength;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyNavigationModel &&
          runtimeType == other.runtimeType &&
          trainIdentification == other.trainIdentification &&
          currentIndex == other.currentIndex &&
          navigationStackLength == other.navigationStackLength;

  @override
  int get hashCode => Object.hash(trainIdentification, currentIndex, navigationStackLength);

  @override
  String toString() =>
      'JourneyNavigationModel(trainIdentification: $trainIdentification, currentIndex: $currentIndex, navigationStackLength: $navigationStackLength)';
}
