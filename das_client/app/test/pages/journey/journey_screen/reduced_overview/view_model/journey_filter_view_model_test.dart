import 'package:app/pages/journey/journey_screen/reduced_overview/model/journey_filter_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/journey_filter_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ru_indications/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../../test_util.dart';
import 'journey_filter_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<JourneyViewModel>()])
void main() {
  late BehaviorSubject<Journey?> journeySubject;
  late JourneyFilterViewModel testee;
  late MockJourneyViewModel journeyViewModel;

  setUp(() {
    journeySubject = BehaviorSubject<Journey?>.seeded(null);
    journeyViewModel = MockJourneyViewModel();
    when(journeyViewModel.journey).thenAnswer((_) => journeySubject.stream);
    testee = JourneyFilterViewModel(journeyViewModel: journeyViewModel);
  });

  tearDown(() async {
    testee.dispose();
    await journeySubject.close();
  });

  test('model_whenJourneyChanges_thenExtractsAllFilterData', () async {
    // GIVEN a journey with data relevant for all filters
    final stopPoint = _servicePoint(order: 100, isStop: true);
    final passPoint = _servicePoint(order: 200, isStop: false);
    final visibleProtectionSection = ProtectionSection(
      isOptional: false,
      isLong: false,
      order: 300,
      kilometre: const [],
    );
    final hiddenProtectionSection = ProtectionSection(
      isOptional: false,
      isLong: false,
      order: 301,
      kilometre: const [],
      lastModificationType: ModificationType.deleted,
      lastModificationDate: DateTime.now().add(const Duration(days: -31)),
    );
    final asr = AdditionalSpeedRestriction(kmFrom: 0, kmTo: 0, orderFrom: 400, orderTo: 401);
    final visibleAsrData = AdditionalSpeedRestrictionData(restrictions: [asr], order: 400, kilometre: const []);
    final operationalIndication = OperationalIndication(order: 500, texts: const ['OPS']);
    final ruIndication = RuIndication(order: 600, title: 'RU', text: 'Text');
    final modifiedSignal = Signal(
      order: 700,
      kilometre: const [],
      lastModificationType: ModificationType.updated,
      lastModificationDate: DateTime.now(),
    );

    final journey = Journey(
      metadata: Metadata(
        shortTermChanges: [
          StopToPassChange(startOrder: passPoint.order, endOrder: passPoint.order, startData: passPoint),
        ],
      ),
      data: [
        stopPoint,
        passPoint,
        visibleProtectionSection,
        hiddenProtectionSection,
        visibleAsrData,
        operationalIndication,
        ruIndication,
        modifiedSignal,
      ],
    );

    // WHEN the journey is emitted
    final streamExpectation = expectLater(
      testee.model,
      emitsInOrder([
        isNull,
        isA<JourneyFilterModel>(),
      ]),
    );
    journeySubject.add(journey);
    await processStreams();
    await streamExpectation;

    // THEN all filter buckets are populated with visible/relevant data only
    final model = testee.modelValue;
    expect(model, isNotNull);
    expect(model!.indication.affectedData, [operationalIndication, ruIndication]);
    expect(model.protectionSections.affectedData, [visibleProtectionSection]);
    expect(model.additionalSpeedRestrictions.affectedData, [visibleAsrData]);
    expect(model.shortTermChanges.affectedData, [passPoint]);
    expect(model.modifications.affectedData, [modifiedSignal]);
  });

  test('toggleFilter_whenCalled_thenTogglesOnlySelectedFilter', () async {
    // GIVEN a journey that initializes filter options
    final indication = OperationalIndication(order: 100, texts: const ['OPS']);
    journeySubject.add(
      Journey(
        metadata: Metadata(),
        data: [_servicePoint(order: 1, isStop: true), indication],
      ),
    );
    await processStreams();

    final initial = testee.modelValue!;

    // WHEN indication filter is toggled
    testee.toggleFilter(initial.indication);
    await processStreams();

    // THEN only indication is active
    final toggled = testee.modelValue!;
    expect(toggled.indication.active, isTrue);
    expect(toggled.protectionSections.active, isFalse);
    expect(toggled.additionalSpeedRestrictions.active, isFalse);
    expect(toggled.shortTermChanges.active, isFalse);
    expect(toggled.modifications.active, isFalse);

    // WHEN toggled again
    testee.toggleFilter(toggled.indication);
    await processStreams();

    // THEN it becomes inactive again
    expect(testee.modelValue!.indication.active, isFalse);
  });

  test('resetFilters_whenFiltersAreActive_thenResetsAllToInactive', () async {
    // GIVEN a journey with multiple filter options
    final indication = OperationalIndication(order: 100, texts: const ['OPS']);
    final section = ProtectionSection(isOptional: false, isLong: false, order: 200, kilometre: const []);
    journeySubject.add(
      Journey(
        metadata: Metadata(),
        data: [_servicePoint(order: 1, isStop: true), indication, section],
      ),
    );
    await processStreams();

    final initial = testee.modelValue!;
    testee.toggleFilter(initial.indication);
    await processStreams();
    testee.toggleFilter(testee.modelValue!.protectionSections);
    await processStreams();

    // WHEN reset is triggered
    testee.resetFilters();
    await processStreams();

    // THEN all filters are inactive
    final reset = testee.modelValue!;
    expect(reset.indication.active, isFalse);
    expect(reset.protectionSections.active, isFalse);
    expect(reset.additionalSpeedRestrictions.active, isFalse);
    expect(reset.shortTermChanges.active, isFalse);
    expect(reset.modifications.active, isFalse);
  });

  test('model_whenJourneyBecomesNull_thenResetsToNull', () async {
    // GIVEN an initialized filter model
    journeySubject.add(
      Journey(
        metadata: Metadata(),
        data: [
          _servicePoint(order: 1, isStop: true),
          OperationalIndication(order: 2, texts: const ['OPS']),
        ],
      ),
    );
    await processStreams();
    expect(testee.modelValue, isNotNull);

    // WHEN journey is set to null
    journeySubject.add(null);
    await processStreams();

    // THEN model resets
    expect(testee.modelValue, isNull);
  });

  test('model_whenJourneyIsUpdated_thenKeepsActiveFilterState', () async {
    // GIVEN an initial journey and an activated indication filter
    final trainIdentification = TrainIdentification(
      companyCode: '11',
      trainNumber: '123',
      date: DateTime(2026, 9, 10),
    );
    final firstIndication = OperationalIndication(order: 2, texts: const ['OPS-1']);
    final secondIndication = OperationalIndication(order: 3, texts: const ['OPS-2']);

    journeySubject.add(
      Journey(
        metadata: Metadata(trainIdentification: trainIdentification),
        data: [_servicePoint(order: 1, isStop: true), firstIndication],
      ),
    );
    await processStreams();

    testee.toggleFilter(testee.modelValue!.indication);
    await processStreams();
    expect(testee.modelValue!.indication.active, isTrue);

    // WHEN the journey is updated for the same train
    journeySubject.add(
      Journey(
        metadata: Metadata(trainIdentification: trainIdentification),
        data: [_servicePoint(order: 1, isStop: true), secondIndication],
      ),
    );
    await processStreams();

    // THEN the active state remains enabled and data is refreshed
    expect(testee.modelValue!.indication.active, isTrue);
    expect(testee.modelValue!.indication.affectedData, [secondIndication]);
  });
}

ServicePoint _servicePoint({required int order, required bool isStop}) {
  return ServicePoint(
    name: '$order',
    abbreviation: '$order',
    locationCode: '$order',
    order: order,
    kilometre: const [],
    isStop: isStop,
  );
}
