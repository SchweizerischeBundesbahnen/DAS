import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  test('text_whenNoTypeAndText_thenReturnsNull', () {
    // GIVEN
    final departureAuth = DepartureAuthorization(types: [], originalText: null);

    // WHEN THEN
    expect(departureAuth.text, isNull);
  });

  test('text_whenDispatcherTypeAndNoText_thenReturnsPrefix', () {
    // GIVEN
    final departureAuth = DepartureAuthorization(types: [.dispatcher], originalText: null);

    // WHEN THEN
    expect(departureAuth.text, '*');
  });

  test('text_whenDispatcherTypeAndText_thenReturnsPrefixedText', () {
    // GIVEN
    final departureAuth = DepartureAuthorization(types: [.dispatcher], originalText: '10-30');

    // WHEN THEN
    expect(departureAuth.text, '* 10-30');
  });

  test('text_whenSmsTypeAndText_thenReturnsText', () {
    // GIVEN
    final departureAuth = DepartureAuthorization(types: [.sms], originalText: 'sms 3-6');

    // WHEN THEN
    expect(departureAuth.text, 'sms 3-6');
  });

  test('text_whenSmsTypeAndNoText_thenReturnsNull', () {
    // GIVEN
    final departureAuth = DepartureAuthorization(types: [.sms], originalText: null);

    // WHEN THEN
    expect(departureAuth.text, isNull);
  });

  test('text_whenSmsAndDispatcherTypeAndNoText_thenReturnsPrefix', () {
    // GIVEN
    final departureAuth = DepartureAuthorization(types: [.sms, .dispatcher], originalText: null);

    // WHEN THEN
    expect(departureAuth.text, '*');
  });

  test('text_whenSmsAndDispatcherTypeAndText_thenReturnsText', () {
    // GIVEN
    final departureAuth = DepartureAuthorization(types: [.sms, .dispatcher], originalText: 'sms 3-6');

    // WHEN THEN
    expect(departureAuth.text, '* sms 3-6');
  });

  test('text_whenTextWithLineBreaks_thenReturnsTextWithSpaces', () {
    // GIVEN
    final departureAuth = DepartureAuthorization(types: [.sms], originalText: 'sms<br/>3-6\n');

    // WHEN THEN
    expect(departureAuth.text, 'sms 3-6 ');
  });

  test('text_whenTextWithLineBreaksAndHTMLFormatting_thenReturnsTextWithSpacesAndFormatting', () {
    // GIVEN
    final departureAuth = DepartureAuthorization(types: [.sms], originalText: 'sms<br/><b>3-6</b>\n');

    // WHEN THEN
    expect(departureAuth.text, 'sms <b>3-6</b> ');
  });
}
