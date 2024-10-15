import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openDrawer(WidgetTester tester) async {
  final ScaffoldState scaffoldState = tester.firstState(find.byType(Scaffold));
  scaffoldState.openDrawer();

  // wait for drawer to open
  await tester.pumpAndSettle(const Duration(milliseconds: 250));
}

Future<void> tapElement(WidgetTester tester, FinderBase<Element> element) async {
  var gestureDetector = find.ancestor(of: element, matching: find.byType(GestureDetector)).first;
  await tester.tap(gestureDetector);

  await tester.pumpAndSettle(const Duration(milliseconds: 250));
}


