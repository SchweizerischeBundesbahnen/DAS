import 'package:app/pages/journey/journey_screen/reduced_overview/model/journey_filter_model.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  test('getFilteredData_whenAllFiltersAreInactive_thenReturnsUnionOfAllAffectedData', () {
    // GIVEN
    final dataA = _servicePoint(order: 100);
    final dataB = _servicePoint(order: 200);
    final dataC = _servicePoint(order: 300);
    final model = JourneyFilterModel(
      indication: _filterOption([dataA]),
      protectionSections: _filterOption([dataB]),
      additionalSpeedRestrictions: _filterOption([dataC]),
      shortTermChanges: _filterOption([]),
      modifications: _filterOption([]),
    );

    // WHEN
    final filteredData = model.getFilteredData();

    // THEN
    expect(filteredData, {dataA, dataB, dataC});
  });

  test('getFilteredData_whenSomeFiltersAreActive_thenExcludesActiveFilterData', () {
    // GIVEN
    final dataA = _servicePoint(order: 100);
    final dataB = _servicePoint(order: 200);
    final dataC = _servicePoint(order: 300);
    final model = JourneyFilterModel(
      indication: _filterOption([dataA], active: true),
      protectionSections: _filterOption([dataB], active: false),
      additionalSpeedRestrictions: _filterOption([dataC], active: true),
      shortTermChanges: _filterOption([]),
      modifications: _filterOption([]),
    );

    // WHEN
    final filteredData = model.getFilteredData();

    // THEN
    expect(filteredData, {dataB});
  });

  test('getFilteredData_whenDataOccursInMultipleFilters_thenReturnsUniqueSet', () {
    // GIVEN
    final shared = _servicePoint(order: 100);
    final model = JourneyFilterModel(
      indication: _filterOption([shared]),
      protectionSections: _filterOption([shared]),
      additionalSpeedRestrictions: _filterOption([]),
      shortTermChanges: _filterOption([]),
      modifications: _filterOption([]),
    );

    // WHEN
    final filteredData = model.getFilteredData();

    // THEN
    expect(filteredData.length, 1);
    expect(filteredData, {shared});
  });

  test('hasData_whenAllFiltersAreEmpty_thenReturnsFalse', () {
    // GIVEN
    final model = JourneyFilterModel(
      indication: _filterOption([]),
      protectionSections: _filterOption([]),
      additionalSpeedRestrictions: _filterOption([]),
      shortTermChanges: _filterOption([]),
      modifications: _filterOption([]),
    );

    // WHEN
    final hasData = model.hasData;

    // THEN
    expect(hasData, isFalse);
  });

  test('hasData_whenAnyFilterHasData_thenReturnsTrue', () {
    // GIVEN
    final model = JourneyFilterModel(
      indication: _filterOption([]),
      protectionSections: _filterOption([]),
      additionalSpeedRestrictions: _filterOption([]),
      shortTermChanges: _filterOption([_servicePoint(order: 100)]),
      modifications: _filterOption([]),
    );

    // WHEN
    final hasData = model.hasData;

    // THEN
    expect(hasData, isTrue);
  });
}

FilterOption _filterOption(List<BaseData> data, {bool active = false}) {
  return FilterOption(active: active, affectedData: data);
}

ServicePoint _servicePoint({required int order}) {
  return ServicePoint(
    name: '$order',
    abbreviation: '$order',
    locationCode: '$order',
    order: order,
    kilometre: const [],
  );
}
