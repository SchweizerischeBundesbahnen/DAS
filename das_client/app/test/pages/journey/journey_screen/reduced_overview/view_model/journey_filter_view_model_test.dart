import 'package:app/pages/journey/journey_screen/reduced_overview/model/journey_filter_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/journey_filter_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ru_indications/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../../test_util.dart';
import 'journey_filter_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
  MockSpec<AcknowledgedModificationRepository>(),
  MockSpec<JourneySettingsViewModel>(),
])
void main() {
  late BehaviorSubject<Journey?> journeySubject;
  late BehaviorSubject<Set<Modification>> acknowledgedModificationsSubject;
  late BehaviorSubject<JourneySettings> journeySettingsSubject;
  late JourneyFilterViewModel testee;
  late MockJourneyViewModel journeyViewModel;
  late MockAcknowledgedModificationRepository acknowledgedModificationRepository;
  late MockJourneySettingsViewModel journeySettingsViewModel;

  setUp(() {
    journeySubject = BehaviorSubject<Journey?>.seeded(null);
    acknowledgedModificationsSubject = BehaviorSubject<Set<Modification>>.seeded({});
    journeySettingsSubject = BehaviorSubject<JourneySettings>.seeded(const JourneySettings());

    journeyViewModel = MockJourneyViewModel();
    acknowledgedModificationRepository = MockAcknowledgedModificationRepository();
    journeySettingsViewModel = MockJourneySettingsViewModel();

    when(journeyViewModel.journey).thenAnswer((_) => journeySubject.stream);

    when(acknowledgedModificationRepository.model).thenAnswer((_) => acknowledgedModificationsSubject.stream);
    when(acknowledgedModificationRepository.modelValue).thenAnswer((_) => acknowledgedModificationsSubject.value);

    when(journeySettingsViewModel.model).thenAnswer((_) => journeySettingsSubject.stream);
    when(journeySettingsViewModel.modelValue).thenAnswer((_) => journeySettingsSubject.value);

    testee = JourneyFilterViewModel(
      journeyViewModel: journeyViewModel,
      acknowledgedModificationRepository: acknowledgedModificationRepository,
      journeySettingsViewModel: journeySettingsViewModel,
    );
  });

  tearDown(() async {
    testee.dispose();
    await journeySubject.close();
    await acknowledgedModificationsSubject.close();
    await journeySettingsSubject.close();
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
      modification: Modification(
        identifier: '301',
        type: ModificationType.deleted,
        date: DateTime.now().add(const Duration(days: -31)),
      ),
    );
    final asr = AdditionalSpeedRestriction(kmFrom: 0, kmTo: 0, orderFrom: 400, orderTo: 401);
    final visibleAsrData = AdditionalSpeedRestrictionData(restrictions: [asr], order: 400, kilometre: const []);
    final operationalIndication = OperationalIndication(order: 500, texts: const ['OPS']);
    final ruIndication = RuIndication(order: 600, title: 'RU', text: 'Text');
    final modifiedSignal = Signal(
      order: 700,
      kilometre: const [],
      modification: Modification(identifier: '700', type: ModificationType.updated, date: DateTime.now()),
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

  test('model_whenModificationIsAcknowledged_thenExcludesFromModificationsFilter', () async {
    // GIVEN a journey with an unacknowledged modified signal
    final modification = Modification(identifier: 'signal-1', type: ModificationType.updated, date: DateTime.now());
    final modifiedSignal = Signal(
      order: 700,
      kilometre: const [],
      modification: modification,
    );
    journeySubject.add(
      Journey(
        metadata: Metadata(),
        data: [_servicePoint(order: 1, isStop: true), modifiedSignal],
      ),
    );
    await processStreams();

    expect(testee.modelValue!.modifications.affectedData, [modifiedSignal]);

    // WHEN the modification is acknowledged
    acknowledgedModificationsSubject.add({modification});
    await processStreams();

    // THEN it is excluded from the modifications filter
    expect(testee.modelValue!.modifications.affectedData, isEmpty);
  });

  test('model_whenShowAcknowledgedModificationsIsTrue_thenIncludesAcknowledgedModifications', () async {
    // GIVEN a journey with an acknowledged modified signal
    final modification = Modification(identifier: 'signal-1', type: ModificationType.updated, date: DateTime.now());
    final modifiedSignal = Signal(
      order: 700,
      kilometre: const [],
      modification: modification,
    );
    acknowledgedModificationsSubject.add({modification});
    journeySubject.add(
      Journey(
        metadata: Metadata(),
        data: [_servicePoint(order: 1, isStop: true), modifiedSignal],
      ),
    );
    await processStreams();

    // Initially excluded because it is acknowledged and showAcknowledgedModifications is false
    expect(testee.modelValue!.modifications.affectedData, isEmpty);

    // WHEN showAcknowledgedModifications is set to true
    journeySettingsSubject.add(const JourneySettings(showAcknowledgedModifications: true));
    await processStreams();

    // THEN it is included in the modifications filter
    expect(testee.modelValue!.modifications.affectedData, [modifiedSignal]);
  });

  test('model_whenDeletedProtectionSectionIsAcknowledged_thenExcludesFromProtectionSections', () async {
    // GIVEN a deleted protection section (deleted within 30 days so !shouldHide is true)
    final modification = Modification(identifier: 'ps-1', type: ModificationType.deleted, date: DateTime.now());
    final protectionSection = ProtectionSection(
      isOptional: false,
      isLong: false,
      order: 300,
      kilometre: const [],
      modification: modification,
    );
    journeySubject.add(
      Journey(
        metadata: Metadata(),
        data: [_servicePoint(order: 1, isStop: true), protectionSection],
      ),
    );
    await processStreams();

    // Unacknowledged deleted section is shown
    expect(testee.modelValue!.protectionSections.affectedData, [protectionSection]);

    // WHEN the modification is acknowledged
    acknowledgedModificationsSubject.add({modification});
    await processStreams();

    // THEN it is excluded from protection sections filter
    expect(testee.modelValue!.protectionSections.affectedData, isEmpty);
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
