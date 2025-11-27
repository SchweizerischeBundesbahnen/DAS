import 'package:app/pages/journey/journey_table/header/departure_authorization/departure_authorization_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('DepartureAuthenticationModel', () {
    test('departureAuthText_whenNoDepartureAuthorization_thenReturnsNull', () {
      // ARRANGE
      final testee = DepartureAuthorizationModel(
        servicePoint: ServicePoint(
          name: 'Servicepoint A',
          abbreviation: 'SA',
          order: 0,
          kilometre: [],
          departureAuthorization: null,
        ),
      );

      // ACT & EXPECT
      expect(testee.departureAuthText, isNull);
    });

    test('departureAuthText_whenNoDepartureAuthorizationText_thenReturnsNull', () {
      // ARRANGE
      final testee = DepartureAuthorizationModel(
        servicePoint: ServicePoint(
          name: 'Servicepoint A',
          abbreviation: 'SA',
          order: 0,
          kilometre: [],
          departureAuthorization: DepartureAuthorization(
            types: [.sms],
          ),
        ),
      );

      // ACT & EXPECT
      expect(testee.departureAuthText, isNull);
    });

    test('departureAuthText_whenGivenDepartureAuthorizationText_thenReturnsTextWithServicePoint', () {
      // ARRANGE
      final testee = DepartureAuthorizationModel(
        servicePoint: ServicePoint(
          name: 'Servicepoint A',
          abbreviation: 'SA',
          order: 0,
          kilometre: [],
          departureAuthorization: DepartureAuthorization(
            types: [.sms],
            originalText: 'sms 2-4',
          ),
        ),
      );

      // ACT & EXPECT
      expect(testee.departureAuthText, '(SA) sms 2-4');
    });
  });
}
