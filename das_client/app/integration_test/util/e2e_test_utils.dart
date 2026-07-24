import 'dart:io';

import 'package:app/brightness/brightness_modal_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

Future<void> optionallyDismissBrightnessModalOnAndroid(WidgetTester tester) async {
  if (Platform.isIOS) return;

  final closeButton = find.byKey(BrightnessModalSheet.dismissButtonKey);
  if (closeButton.evaluate().isNotEmpty) {
    await tapElement(tester, closeButton);
  }
  await Future.delayed(const Duration(milliseconds: 100));
}
