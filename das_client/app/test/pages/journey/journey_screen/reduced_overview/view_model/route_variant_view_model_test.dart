import 'package:app/pages/journey/journey_screen/reduced_overview/model/route_variant.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/route_variant_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../../test_util.dart';
import 'route_variant_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<JourneyViewModel>()])
void main() {
  late BehaviorSubject<Journey?> journeySubject;
  late RouteVariantViewModel testee;
  late MockJourneyViewModel mockJourneyViewModel;

  setUp(() {
    mockJourneyViewModel = MockJourneyViewModel();
    journeySubject = BehaviorSubject<Journey?>.seeded(null);
    when(mockJourneyViewModel.journey).thenAnswer((_) => journeySubject.stream);
    testee = RouteVariantViewModel(journeyViewModel: mockJourneyViewModel);
  });

  tearDown(() async {
    testee.dispose();
    await journeySubject.close();
  });

  test('variantsByOrder_whenJourneyChanges_thenEmitsResolvedMap', () async {
    // GIVEN a journey containing Loetschberg Basistunnel section
    final servicePoints = [
      _servicePoint(order: 1, locationCode: 'CH07478'),
      _servicePoint(order: 2, locationCode: 'CH15669'),
      _servicePoint(order: 3, locationCode: 'CH01609', isStop: true),
    ];
    final journey = Journey(metadata: Metadata(), data: servicePoints);

    final expectedVariantMap = {
      3: RouteVariant.loetschbergViaBasistunnel,
    };

    // WHEN the journey is emitted
    final streamExpectation = expectLater(
      testee.variantsByOrder,
      emitsInOrder([
        isEmpty,
        expectedVariantMap,
      ]),
    );

    journeySubject.add(journey);
    await processStreams();
    await streamExpectation;

    // THEN the latest value mirrors the last stream emission
    expect(testee.variantsByOrderValue, expectedVariantMap);
  });

  test('variantsByOrder_whenJourneyBecomesNull_thenEmitsEmptyMap', () async {
    // GIVEN a journey with one route variant followed by null
    final streamExpectation = expectLater(
      testee.variantsByOrder,
      emitsInOrder([
        isEmpty,
        {
          12: RouteVariant.eppenbergtunnelViaSchoenenwerd,
        },
        isEmpty,
      ]),
    );

    journeySubject.add(
      Journey(
        metadata: Metadata(),
        data: [
          _servicePoint(order: 10, locationCode: 'CH02111'),
          _servicePoint(order: 11, locationCode: 'CH19045'),
          _servicePoint(order: 12, locationCode: 'CH02125'),
        ],
      ),
    );
    await processStreams();

    // WHEN a null journey is emitted
    journeySubject.add(null);
    await processStreams();
    await streamExpectation;

    // THEN variants are reset
    expect(testee.variantsByOrderValue, isEmpty);
  });

  test('variantsByOrder_whenBoundaryPointsAreReversed_thenStillResolvesVariant', () async {
    // GIVEN section boundary points in reverse order
    final streamExpectation = expectLater(
      testee.variantsByOrder,
      emitsInOrder([
        isEmpty,
        {
          1: RouteVariant.loetschbergViaBasistunnel,
        },
      ]),
    );

    // WHEN the journey is emitted
    journeySubject.add(
      Journey(
        metadata: Metadata(),
        data: [
          _servicePoint(order: 1, locationCode: 'CH01609', isStop: true),
          _servicePoint(order: 2, locationCode: 'CH15669'),
          _servicePoint(order: 3, locationCode: 'CH07478'),
        ],
      ),
    );
    await processStreams();
    await streamExpectation;
  });

  test('variantsByOrder_whenBp3IsMissing_thenFallsBackToNullBp3Variant', () async {
    // GIVEN only boundary points for Eppenbergtunnel without explicit BP3 location
    final streamExpectation = expectLater(
      testee.variantsByOrder,
      emitsInOrder([
        isEmpty,
        {
          11: RouteVariant.eppenbergtunnelViaEppenbergtunnel,
        },
      ]),
    );

    // WHEN the journey is emitted
    journeySubject.add(
      Journey(
        metadata: Metadata(),
        data: [
          _servicePoint(order: 10, locationCode: 'CH02111'),
          _servicePoint(order: 11, locationCode: 'CH02125', isStop: true),
        ],
      ),
    );
    await processStreams();
    await streamExpectation;
  });

  test('variantsByOrder_whenLocationCodesAreLowercase_thenStillResolvesVariant', () async {
    // GIVEN journey data with lowercase location codes
    final streamExpectation = expectLater(
      testee.variantsByOrder,
      emitsInOrder([
        isEmpty,
        {
          3: RouteVariant.loetschbergViaBasistunnel,
        },
      ]),
    );

    // WHEN the journey is emitted
    journeySubject.add(
      Journey(
        metadata: Metadata(),
        data: [
          _servicePoint(order: 1, locationCode: 'ch07478'),
          _servicePoint(order: 2, locationCode: 'ch15669'),
          _servicePoint(order: 3, locationCode: 'ch01609', isStop: true),
        ],
      ),
    );
    await processStreams();
    await streamExpectation;
  });

  test('variantsByOrder_whenJourneyContainsMultipleSections_thenResolvesAllVariants', () async {
    // GIVEN a journey containing two independent variant sections
    final streamExpectation = expectLater(
      testee.variantsByOrder,
      emitsInOrder([
        isEmpty,
        {
          3: RouteVariant.loetschbergViaBasistunnel,
          6: RouteVariant.eppenbergtunnelViaSchoenenwerd,
        },
      ]),
    );

    // WHEN the journey is emitted
    journeySubject.add(
      Journey(
        metadata: Metadata(),
        data: [
          _servicePoint(order: 1, locationCode: 'CH07478'),
          _servicePoint(order: 2, locationCode: 'CH15669'),
          _servicePoint(order: 3, locationCode: 'CH01609', isStop: true),
          _servicePoint(order: 4, locationCode: 'CH02111'),
          _servicePoint(order: 5, locationCode: 'CH19045'),
          _servicePoint(order: 6, locationCode: 'CH02125', isStop: true),
        ],
      ),
    );
    await processStreams();
    await streamExpectation;
  });

  test('variantsByOrder_whenSectionHasMultipleStopsOrNoStop_thenUsesExpectedAnchorPoint', () async {
    // GIVEN one section with multiple stops and one section without stops
    final streamExpectation = expectLater(
      testee.variantsByOrder,
      emitsInOrder([
        isEmpty,
        {
          12: RouteVariant.eppenbergtunnelViaSchoenenwerd,
        },
        {
          20: RouteVariant.eppenbergtunnelViaSchoenenwerd,
        },
      ]),
    );

    // WHEN the journey contains multiple stops within the same section
    journeySubject.add(
      Journey(
        metadata: Metadata(),
        data: [
          _servicePoint(order: 10, locationCode: 'CH02111'),
          _servicePoint(order: 11, locationCode: 'CH19045', isStop: true),
          _servicePoint(order: 12, locationCode: 'CH02125', isStop: true),
        ],
      ),
    );
    await processStreams();

    // WHEN no stop exists in the section
    journeySubject.add(
      Journey(
        metadata: Metadata(),
        data: [
          _servicePoint(order: 18, locationCode: 'CH02111'),
          _servicePoint(order: 19, locationCode: 'CH19045'),
          _servicePoint(order: 20, locationCode: 'CH02125'),
        ],
      ),
    );
    await processStreams();
    await streamExpectation;
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
