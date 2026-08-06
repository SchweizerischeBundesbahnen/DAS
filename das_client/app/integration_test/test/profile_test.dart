import 'package:app/widgets/railway_undertaking/widgets/select_railway_undertaking_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../integration/integration_test_app.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('profile_whenOpened_thenShowsHeaderInformation|asZ1tS4kU7Nf5OXr8iPr|tests:427', (tester) async {
    await IntegrationTestApp.start(tester);
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

    expect(find.text('Integration Tester'), findsAny);
    expect(find.text('tester@testeee.com'), findsAny);
  });

  testWidgets('profile_whenRuSelected_thenDisplaysSelection|O7WL0FgVcL2yp91SBkO3|tests:427', (tester) async {
    await IntegrationTestApp.start(tester);
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

    // check initial RU is empty
    expect(find.text(l10n.p_train_selection_ru_description), findsNWidgets(2));

    await tapElement(tester, find.byWidgetPredicate((it) => it is SelectRailwayUndertakingInput));

    // select 3 RU
    await tapElement(tester, find.text(l10n.c_ru_bls_i).first);
    await tapElement(tester, find.text(l10n.c_ru_bls_c).first);
    await tapElement(tester, find.text(l10n.c_ru_db).first);

    await tapElement(
      tester,
      find.byWidgetPredicate(
        (it) => it is IconButton && it.icon is Icon && (it.icon as Icon).icon == SBBIcons.cross_small,
      ),
    );
    await tester.pumpAndSettle(Duration(seconds: 1));

    // check that selected RU are shown in profile
    final evuText = '${l10n.c_ru_bls_i}, ${l10n.c_ru_bls_c}, ${l10n.c_ru_db}';
    expect(find.text(evuText), findsOneWidget);

    await tapElement(
      tester,
      find.text(evuText),
    );

    await tapElement(tester, find.text(l10n.c_ru_bls_c).first);

    await tapElement(
      tester,
      find.byWidgetPredicate(
        (it) => it is IconButton && it.icon is Icon && (it.icon as Icon).icon == SBBIcons.cross_small,
      ),
    );

    final evuText2 = '${l10n.c_ru_bls_i}, ${l10n.c_ru_db}';
    expect(find.text(evuText2), findsOneWidget);
  });

  testWidgets('profile_whenTourSystemSelected_thenDisplaysSelection|Vg694p8aplw0hptHokay|tests:427', (tester) async {
    await IntegrationTestApp.start(tester);
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

    // check initial RU is empty
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
