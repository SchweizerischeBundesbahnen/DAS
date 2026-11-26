import 'package:app/pages/journey/journey_screen/header/view_model/model/radio_channel_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  group('RadioChannelModel', () {
    test('mainContactsIdentifier_whenMainContactsNotEmpty_thenReturnsConcatenatedIdentifiers', () {
      // GIVEN
      final testee = RadioChannelModel(
        radioContacts: RadioContactList(
          contacts: [
            MainContact(contactIdentifier: '123'),
            MainContact(contactIdentifier: '456'),
            MainContact(contactIdentifier: '789'),
          ],
          order: 0,
          endOrder: 0,
        ),
      );

      // WHEN & THEN
      expect(testee.mainContactsIdentifier, '123 456');
    });

    test('mainContactsIdentifier_whenSingleMainContact_thenReturnsSingleIdentifier', () {
      // GIVEN
      final testee = RadioChannelModel(
        radioContacts: RadioContactList(
          contacts: [
            MainContact(contactIdentifier: '123'),
          ],
          order: 0,
          endOrder: 0,
        ),
      );

      // WHEN & THEN
      expect(testee.mainContactsIdentifier, '123');
    });

    test(
      'mainContactsIdentifier_whenMainContactsEmpty_thenReturnsNull',
      () => expect(RadioChannelModel().mainContactsIdentifier, null),
    );

    test('showDotIndicator_whenMainContactsMoreThanOne_thenReturnsTrue', () {
      // GIVEN
      final testee = RadioChannelModel(
        radioContacts: RadioContactList(
          contacts: [
            MainContact(contactIdentifier: '123'),
            MainContact(contactIdentifier: '456'),
          ],
          order: 0,
          endOrder: 0,
        ),
      );

      // WHEN & THEN
      expect(testee.showDotIndicator, true);
    });

    test('showDotIndicator_whenSelectiveContactsNotEmpty_thenReturnsTrue', () {
      // GIVEN
      final testee = RadioChannelModel(
        radioContacts: RadioContactList(
          contacts: [
            SelectiveContact(contactIdentifier: '123'),
          ],
          order: 0,
          endOrder: 0,
        ),
      );

      // WHEN
      final showDot = testee.showDotIndicator;

      // THEN
      expect(showDot, true);
    });

    test('showDotIndicator_whenOneMainContactsAndSelectiveContactsEmpty_thenReturnsFalse', () {
      // GIVEN
      final testee = RadioChannelModel(
        radioContacts: RadioContactList(
          contacts: [
            MainContact(contactIdentifier: '123'),
          ],
          order: 0,
          endOrder: 0,
        ),
      );

      // WHEN
      final showDot = testee.showDotIndicator;

      // THEN
      expect(showDot, false);
    });

    test('equality_whenPropertiesAreEqual_thenObjectsAreEqual', () {
      // GIVEN
      final model1 = RadioChannelModel(
        networkType: .gsmR,
        lastServicePoint: null,
        radioContacts: RadioContactList(contacts: [MainContact(contactIdentifier: '123')], order: 0, endOrder: 0),
      );
      final model2 = RadioChannelModel(
        networkType: .gsmR,
        lastServicePoint: null,
        radioContacts: RadioContactList(contacts: [MainContact(contactIdentifier: '123')], order: 0, endOrder: 0),
      );

      // WHEN & THEN
      expect(model1 == model2, true);
    });

    test('equality_whenPropertiesAreDifferent_thenObjectsAreNotEqual', () {
      // GIVEN
      final model1 = RadioChannelModel(
        networkType: .gsmR,
        lastServicePoint: null,
        radioContacts: RadioContactList(contacts: [MainContact(contactIdentifier: '123')], order: 0, endOrder: 0),
      );
      final model2 = RadioChannelModel(
        networkType: .gsmP,
        lastServicePoint: null,
        radioContacts: RadioContactList(contacts: [MainContact(contactIdentifier: '123')], order: 0, endOrder: 0),
      );

      // WHEN & THEN
      expect(model1 == model2, false);
    });

    test('hashCode_whenPropertiesAreEqual_thenHashCodesAreEqual', () {
      // GIVEN
      final model1 = RadioChannelModel(
        networkType: .gsmR,
        lastServicePoint: null,
        radioContacts: RadioContactList(contacts: [MainContact(contactIdentifier: '123')], order: 0, endOrder: 0),
      );
      final model2 = RadioChannelModel(
        networkType: .gsmR,
        lastServicePoint: null,
        radioContacts: RadioContactList(contacts: [MainContact(contactIdentifier: '123')], order: 0, endOrder: 0),
      );

      // WHEN & THEN
      expect(model1.hashCode, model2.hashCode);
    });
  });
}
