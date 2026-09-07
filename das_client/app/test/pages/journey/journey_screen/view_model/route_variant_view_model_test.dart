import 'package:app/pages/journey/journey_screen/view_model/route_variant_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/route_variant.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('RouteVariantResolver', () {
    test('resolves Loetschberg Basistunnel and anchors at first stop in section', () {
      final servicePoints = [
        _servicePoint(order: 1, locationCode: 'CH07478'),
        _servicePoint(order: 2, locationCode: 'CH15669'),
        _servicePoint(order: 3, locationCode: 'CH01609', isStop: true),
      ];

      final resolved = RouteVariantViewModel.resolveVariants(servicePoints);

      expect(resolved[3], RouteVariant.loetschbergViaBasistunnel);
      expect(resolved.length, 1);
    });

    test('prefers explicit BP3 match over fallback variant for Eppenbergtunnel', () {
      final servicePoints = [
        _servicePoint(order: 10, locationCode: 'CH02111'),
        _servicePoint(order: 11, locationCode: 'CH19045'),
        _servicePoint(order: 12, locationCode: 'CH02125'),
      ];

      final resolved = RouteVariantViewModel.resolveVariants(servicePoints);

      expect(resolved[10], RouteVariant.eppenbergtunnelViaSchoenenwerd);
      expect(resolved.length, 1);
    });

    test('matches Wanzwil locationCode and falls back to first point when no stop exists', () {
      final servicePoints = [
        _servicePoint(order: 20, locationCode: 'CH08103'),
        _servicePoint(order: 21, locationCode: 'CH08047', isAdditional: true),
        _servicePoint(order: 22, locationCode: 'CH08042'),
      ];

      final resolved = RouteVariantViewModel.resolveVariants(servicePoints);

      expect(resolved[20], RouteVariant.nbsBahn2000ViaNbs);
      expect(resolved.length, 1);
    });
  });
}

ServicePoint _servicePoint({
  required int order,
  required String locationCode,
  bool isStop = false,
  bool isAdditional = false,
}) {
  return ServicePoint(
    name: locationCode,
    abbreviation: locationCode,
    locationCode: locationCode,
    order: order,
    kilometre: const [],
    isStop: isStop,
    isAdditional: isAdditional,
  );
}
