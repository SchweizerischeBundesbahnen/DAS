import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openDrawer(WidgetTester tester) async {
  final ScaffoldState scaffoldState = tester.firstState(find.byType(Scaffold));
  scaffoldState.openDrawer();

  // wait for drawer to open
  await tester.pumpAndSettle(const Duration(milliseconds: 250));
}

Future<void> tapElement(WidgetTester tester, FinderBase<Element> element) async {
  await tester.tap(element);
  await tester.pumpAndSettle();
}

Future<void> enterText(WidgetTester tester, FinderBase<Element> element, String text) async {
  await tester.enterText(element, text);
  await tester.pumpAndSettle();
}

Finder findTextFieldByLabel(String label) {
  final sbbTextField = find.byWidgetPredicate((widget) => widget is SBBTextField && widget.labelText == label);
  return find.descendant(of: sbbTextField, matching: find.byType(TextField));
}
