import 'package:app/widgets/company_selection/widgets/select_company_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../integration/integration_test_app.dart';
import '../mocks/mock_settings_repository.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('profile_whenOpened_thenShowsHeaderInformation|asZ1tS4kU7Nf5OXr8iPr|tests:427', (tester) async {
    await IntegrationTestApp.start(tester);
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

    expect(find.text('Integration Tester'), findsAny);
    expect(find.text('tester@testeee.com'), findsAny);
  });

  testWidgets('profile_whenCompanySelected_thenDisplaysSelection|O7WL0FgVcL2yp91SBkO3|tests:427', (tester) async {
    await IntegrationTestApp.start(tester);
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

    // check initial company is empty
    expect(find.text(l10n.p_train_selection_company_description), findsNWidgets(2));

    await tapElement(tester, find.byWidgetPredicate((it) => it is SelectCompanyInput));

    // select 3 companies
    await tapElement(tester, find.text(companyBLSI.shortName).first);
    await tapElement(tester, find.text(companyBLSC.shortName).first);
    await tapElement(tester, find.text(companyDB.shortName).first);

    await _closeModal(tester);
    await tester.pumpAndSettle(Duration(seconds: 1));

    // check that selected companies are shown in profile in alphabetical order
    final evuText = '${companyBLSC.shortName}, ${companyBLSI.shortName}, ${companyDB.shortName}';
    expect(find.text(evuText), findsOneWidget);

    await tapElement(tester, find.text(evuText));
    await tapElement(tester, find.text(companyBLSC.shortName).first);

    await _closeModal(tester);

    final evuText2 = '${companyBLSI.shortName}, ${companyDB.shortName}';
    expect(find.text(evuText2), findsOneWidget);
  });

  testWidgets('profile_whenTourSystemSelected_thenDisplaysSelection|Vg694p8aplw0hptHokay|tests:427', (tester) async {
    await IntegrationTestApp.start(tester);
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

    // check initial company is empty
    expect(find.text(l10n.w_user_tour_system_selection_label), findsNWidgets(2));

    await tapElement(tester, find.byWidgetPredicate((it) => it is SBBDropdown));

    // Select tour system
    await tapElement(tester, find.text(l10n.c_tour_system_rail_cube).first);

    expect(find.text(l10n.c_tour_system_rail_cube), findsOne);

    await tapElement(tester, find.byWidgetPredicate((it) => it is SBBDropdown));
    await tapElement(tester, find.text(l10n.c_tour_system_bls_ivu).first);

    expect(find.text(l10n.c_tour_system_bls_ivu), findsOne);
  });
}

Future<void> _closeModal(WidgetTester tester) async {
  await tapElement(
    tester,
    find.byWidgetPredicate(
      (it) => it is IconButton && it.icon is Icon && (it.icon as Icon).icon == SBBIcons.cross_small,
    ),
  );
}
