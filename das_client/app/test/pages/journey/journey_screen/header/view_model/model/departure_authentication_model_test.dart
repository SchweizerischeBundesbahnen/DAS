import 'package:app/pages/journey/journey_screen/header/view_model/model/departure_authorization_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('DepartureAuthenticationModel', () {
    test('departureAuthText_whenNoDepartureAuthorization_thenReturnsNull', () {
      // GIVEN
      final testee = DepartureAuthorizationModel(
        servicePoint: ServicePoint(
          name: 'Servicepoint A',
          abbreviation: 'SA',
          locationCode: '',
          order: 0,
          kilometre: [],
          departureAuthorization: null,
        ),
      );

      // WHEN & THEN
      expect(testee.departureAuthText, isNull);
    });

    test('departureAuthText_whenNoDepartureAuthorizationText_thenReturnsNull', () {
      // GIVEN
      final testee = DepartureAuthorizationModel(
        servicePoint: ServicePoint(
          name: 'Servicepoint A',
          abbreviation: 'SA',
          locationCode: '',
          order: 0,
          kilometre: [],
          departureAuthorization: DepartureAuthorization(
            types: [.sms],
          ),
        ),
      );

      // WHEN & THEN
      expect(testee.departureAuthText, isNull);
    });

    test('departureAuthText_whenGivenDepartureAuthorizationText_thenReturnsTextWithServicePoint', () {
      // GIVEN
      final testee = DepartureAuthorizationModel(
        servicePoint: ServicePoint(
          name: 'Servicepoint A',
          abbreviation: 'SA',
          locationCode: '',
          order: 0,
          kilometre: [],
          departureAuthorization: DepartureAuthorization(
            types: [.sms],
            originalText: 'sms 2-4',
          ),
        ),
      );

      // WHEN & THEN
      expect(testee.departureAuthText, '(SA) sms 2-4');
    });
  });
}
