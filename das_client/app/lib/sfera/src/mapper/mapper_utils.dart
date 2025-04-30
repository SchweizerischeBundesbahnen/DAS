import 'package:app/sfera/src/model/segment_profile.dart';

const int _hundredThousand = 100000;

int calculateOrder(int segmentIndex, double location) {
  return (segmentIndex * _hundredThousand + location).toInt();
}

typedef KilometreMap = Map<double, List<double>>;

KilometreMap parseKilometre(SegmentProfile segmentProfile) {
  final kilometreMap = <double, List<double>>{};
  if (segmentProfile.contextInformation != null) {
    for (final kilometreReferencePoint in segmentProfile.contextInformation!.kilometreReferencePoints) {
      if (!kilometreMap.containsKey(kilometreReferencePoint.location)) {
        kilometreMap[kilometreReferencePoint.location] = [];
      }
      kilometreMap[kilometreReferencePoint.location]!.add(kilometreReferencePoint.kmReference.kmRef);
    }
  }
  return kilometreMap;
}
