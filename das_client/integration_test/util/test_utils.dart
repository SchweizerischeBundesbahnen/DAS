import 'package:das_client/app/widgets/table/das_table.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
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

Finder findDASTableRowByText(String text) {
  return find.ancestor(of: find.text(text), matching: find.byKey(DASTable.rowKey));
}
