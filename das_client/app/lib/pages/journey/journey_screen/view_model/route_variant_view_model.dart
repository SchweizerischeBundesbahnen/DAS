import 'package:app/pages/journey/journey_screen/view_model/model/route_variant.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class RouteVariantViewModel extends JourneyAwareViewModel {
  RouteVariantViewModel({super.journeyViewModel}) {
    _updateVariants(lastJourney);
  }

  Map<int, RouteVariant> _variantsByOrder = const {};

  RouteVariant? getRouteVariant(ServicePoint servicePoint) => _variantsByOrder[servicePoint.order];

  @override
  void onJourneyChanged(Journey? journey) => _updateVariants(journey);

  @override
  void onJourneyUpdated(Journey? journey) => _updateVariants(journey);

  void _updateVariants(Journey? journey) {
    final servicePoints = journey?.data.whereType<ServicePoint>() ?? const <ServicePoint>[];
    _variantsByOrder = resolveVariants(servicePoints);
  }

  static Map<int, RouteVariant> resolveVariants(Iterable<ServicePoint> servicePoints) {
    final points = servicePoints.toList();
    if (points.isEmpty) return const {};

    final variantsByOrder = <int, RouteVariant>{};
    for (final group in _variantsByBoundary.values) {
      final bp1Code = group.first.bp1LocationCode.toUpperCase();
      final bp2Code = group.first.bp2LocationCode.toUpperCase();

      final bp1Index = points.indexWhere((it) => _locationCodeOf(it) == bp1Code);
      final bp2Index = points.indexWhere((it) => _locationCodeOf(it) == bp2Code);
      if (bp1Index == -1 || bp2Index == -1) continue;

      final startIndex = bp1Index < bp2Index ? bp1Index : bp2Index;
      final endIndex = bp1Index < bp2Index ? bp2Index : bp1Index;
      final section = points.sublist(startIndex, endIndex + 1);
      final sectionCodes = section.map(_locationCodeOf).toSet();

      final matchedVariant =
          group.firstWhereOrNull(
            (it) => it.bp3LocationCode != null && sectionCodes.contains(it.bp3LocationCode!.toUpperCase()),
          ) ??
          group.firstWhereOrNull((it) => it.bp3LocationCode == null);
      if (matchedVariant == null) continue;

      final anchorPoint = section.firstWhereOrNull((it) => it.isStop) ?? section.first;
      variantsByOrder[anchorPoint.order] = matchedVariant;
    }

    return variantsByOrder;
  }

  static final Map<String, List<RouteVariant>> _variantsByBoundary = RouteVariant.values.groupListsBy(
    (it) => '${it.bp1LocationCode}|${it.bp2LocationCode}',
  );

  static String _locationCodeOf(ServicePoint point) => point.locationCode.toUpperCase();
}
