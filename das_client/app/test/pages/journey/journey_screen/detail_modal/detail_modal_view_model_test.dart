import 'package:app/pages/journey/journey_screen/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_builder.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/brake_load_slip_modal/brake_load_slip_modal_builder.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_builder.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_tab.dart';
import 'package:app/util/time_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sfera/component.dart';

void main() {
  late DetailModalViewModel testee;

  final servicePointBern = ServicePoint(
    name: 'Bern',
    abbreviation: 'BN',
    order: 0,
    kilometre: [],
    locationCode: 'CH0001',
  );
  final servicePointOlten = ServicePoint(
    name: 'Olten',
    abbreviation: 'OL',
    order: 100,
    kilometre: [],
    locationCode: 'CH0002',
  );

  final asrRowA = AdditionalSpeedRestrictionData(
    order: 0,
    kilometre: [0.0],
    restrictions: [
      AdditionalSpeedRestriction(kmFrom: 0.0, kmTo: 1.0, orderFrom: 0, orderTo: 1, speed: 60),
    ],
  );
  final asrRowB = AdditionalSpeedRestrictionData(
    order: 10,
    kilometre: [10.0],
    restrictions: [
      AdditionalSpeedRestriction(kmFrom: 10.0, kmTo: 11.0, orderFrom: 10, orderTo: 11, speed: 40),
    ],
  );

  setUp(() {
    GetIt.I.registerSingleton<TimeConstants>(const TimeConstants());
    testee = DetailModalViewModel();
  });

  tearDown(() {
    testee.dispose();
    GetIt.I.reset();
  });

  test('open_whenCalledFirstTime_thenOpensModalWithMatchingType', () {
    testee.open(
      ServicePointModalBuilder(),
      contentKey: (tab: ServicePointModalTab.communication, servicePoint: servicePointBern),
    );

    expect(testee.isModalOpenValue, isTrue);
    expect(testee.openModalTypeValue, DetailModalType.servicePointModal);
  });

  test('open_whenCalledTwiceWithSameTypeAndContentKey_thenClosesModal', () async {
    expectLater(
      testee.contentBuilder,
      emitsInOrder([isA<ServicePointModalBuilder>(), isNull]),
    );

    testee.open(
      ServicePointModalBuilder(),
      contentKey: (tab: ServicePointModalTab.communication, servicePoint: servicePointBern),
    );
    testee.open(
      ServicePointModalBuilder(),
      contentKey: (tab: ServicePointModalTab.communication, servicePoint: servicePointBern),
    );

    await pumpEventQueue();
  });

  test('open_whenCalledWithSameTypeButDifferentServicePoint_thenSwitchesContentWithoutClosing', () async {
    final emissions = <bool>[];
    testee.contentBuilder.listen((builder) => emissions.add(builder != null));

    testee.open(
      ServicePointModalBuilder(),
      contentKey: (tab: ServicePointModalTab.communication, servicePoint: servicePointBern),
    );
    testee.open(
      ServicePointModalBuilder(),
      contentKey: (tab: ServicePointModalTab.communication, servicePoint: servicePointOlten),
    );

    await pumpEventQueue();

    // content is replaced directly, never cleared to null in between
    expect(emissions, [true, true]);
    expect(testee.isModalOpenValue, isTrue);
    expect(testee.openModalTypeValue, DetailModalType.servicePointModal);
  });

  test('open_whenCalledWithSameTypeButDifferentTab_thenSwitchesContentWithoutClosing', () async {
    final emissions = <bool>[];
    testee.contentBuilder.listen((builder) => emissions.add(builder != null));

    testee.open(
      ServicePointModalBuilder(),
      contentKey: (tab: ServicePointModalTab.communication, servicePoint: servicePointBern),
    );
    testee.open(
      ServicePointModalBuilder(),
      contentKey: (tab: ServicePointModalTab.graduatedSpeeds, servicePoint: servicePointBern),
    );

    await pumpEventQueue();

    expect(emissions, [true, true]);
    expect(testee.isModalOpenValue, isTrue);
  });

  test('open_whenCalledWithDifferentType_thenSwitchesContentWithoutClosing', () async {
    final emissions = <bool>[];
    testee.contentBuilder.listen((builder) => emissions.add(builder != null));

    testee.open(AdditionalSpeedRestrictionModalBuilder(), contentKey: asrRowA);
    testee.open(
      ServicePointModalBuilder(),
      contentKey: (tab: ServicePointModalTab.communication, servicePoint: servicePointBern),
    );

    await pumpEventQueue();

    expect(emissions, [true, true]);
    expect(testee.openModalTypeValue, DetailModalType.servicePointModal);
  });

  test('open_whenAsrRowTappedTwice_thenClosesModal', () async {
    expectLater(
      testee.contentBuilder,
      emitsInOrder([isA<AdditionalSpeedRestrictionModalBuilder>(), isNull]),
    );

    testee.open(AdditionalSpeedRestrictionModalBuilder(), contentKey: asrRowA);
    testee.open(AdditionalSpeedRestrictionModalBuilder(), contentKey: asrRowA);

    await pumpEventQueue();
  });

  test('open_whenDifferentAsrRowTapped_thenSwitchesContentWithoutClosing', () async {
    final emissions = <bool>[];
    testee.contentBuilder.listen((builder) => emissions.add(builder != null));

    testee.open(AdditionalSpeedRestrictionModalBuilder(), contentKey: asrRowA);
    testee.open(AdditionalSpeedRestrictionModalBuilder(), contentKey: asrRowB);

    await pumpEventQueue();

    expect(emissions, [true, true]);
    expect(testee.isModalOpenValue, isTrue);
  });

  test('open_whenBrakeSlipOpenedTwice_thenClosesModal', () async {
    expectLater(
      testee.contentBuilder,
      emitsInOrder([isA<BrakeLoadSlipModalBuilder>(), isNull]),
    );

    // brake slip modal has no distinguishing content, so any two opens while it is
    // already showing are considered the same content, regardless of which
    // element triggered them (header button vs. notification banner)
    testee.open(BrakeLoadSlipModalBuilder());
    testee.open(BrakeLoadSlipModalBuilder());

    await pumpEventQueue();
  });

  test('setMaximized_whenCalled_thenDoesNotAffectOpenContentOrType', () async {
    testee.open(
      ServicePointModalBuilder(),
      contentKey: (tab: ServicePointModalTab.communication, servicePoint: servicePointBern),
    );

    final emissions = <bool>[];
    // skip(1): a BehaviorSubject replays its current value to new listeners, which isn't a new emission
    testee.contentBuilder.skip(1).listen((builder) => emissions.add(builder != null));

    // e.g. switching tabs of an already open modal only resizes it, it never closes or re-opens
    testee.setMaximized(true);
    testee.setMaximized(false);

    await pumpEventQueue();

    expect(emissions, isEmpty);
    expect(testee.isModalOpenValue, isTrue);
    expect(testee.openModalTypeValue, DetailModalType.servicePointModal);
  });

  test('open_whenBrakeSlipOpened_thenDisablesAutomaticCloseOnController', () {
    testee.open(BrakeLoadSlipModalBuilder());

    // brake/load slip modal must never close on its own, see issue #1867
    expect(testee.controller.automaticCloseEnabled, isFalse);
  });

  test('open_whenServicePointOpenedAfterBrakeSlip_thenReenablesAutomaticCloseOnController', () {
    testee.open(BrakeLoadSlipModalBuilder());
    expect(testee.controller.automaticCloseEnabled, isFalse);

    testee.open(
      ServicePointModalBuilder(),
      contentKey: (tab: ServicePointModalTab.communication, servicePoint: servicePointBern),
    );

    expect(testee.controller.automaticCloseEnabled, isTrue);
  });

  test('open_whenServicePointOpened_thenAutomaticCloseOnControllerStaysEnabled', () {
    testee.open(
      ServicePointModalBuilder(),
      contentKey: (tab: ServicePointModalTab.communication, servicePoint: servicePointBern),
    );

    expect(testee.controller.automaticCloseEnabled, isTrue);
  });

  test('close_whenCalled_thenClearsContentBuilder', () async {
    expectLater(
      testee.contentBuilder,
      emitsInOrder([isA<ServicePointModalBuilder>(), isNull]),
    );

    testee.open(
      ServicePointModalBuilder(),
      contentKey: (tab: ServicePointModalTab.communication, servicePoint: servicePointBern),
    );
    testee.close();

    await pumpEventQueue();
  });
}
