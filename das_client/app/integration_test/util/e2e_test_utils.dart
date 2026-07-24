import 'dart:async';
import 'dart:io';

import 'package:app/brightness/brightness_modal_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

FutureOr<void> optionallyDismissBrightnessModalOnAndroid(WidgetTester tester) async {
  if (Platform.isIOS) return;

  await tester.pumpAndSettle(const Duration(milliseconds: 300));
  final brightnessModal = find.byType(BrightnessModalSheet);
  if (brightnessModal.evaluate().isNotEmpty) {
    await tester.tapAt(Offset(10, 10));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }
}
