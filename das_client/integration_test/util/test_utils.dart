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

Future<void> tapAt(WidgetTester tester, FinderBase<Element> finder) async {
  final single = finder.evaluate().single;
  final RenderBox box = single.renderObject! as RenderBox;
  final Offset location = box.localToGlobal(box.size.center(Offset.zero));
  await tester.tapAt(location);
  await tester.pumpAndSettle();
}

Finder findTextFieldByLabel(String label) {
  var sbbTextField = find.byWidgetPredicate((widget) => widget is SBBTextField && widget.labelText == label);
  return find.descendant(of: sbbTextField, matching: find.byType(TextField));
}
