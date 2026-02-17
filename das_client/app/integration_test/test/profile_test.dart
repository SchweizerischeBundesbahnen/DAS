import 'package:app/widgets/railway_undertaking/widgets/select_railway_undertaking_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test profile page header', (tester) async {
    await prepareAndStartApp(tester);
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

    expect(find.text('Integration Tester'), findsAny);
    expect(find.text('tester@testeee.com'), findsAny);
  });

  testWidgets('test user ru profile selection', (tester) async {
    await prepareAndStartApp(tester);
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

    // check initial RU is empty
    expect(find.text(l10n.p_train_selection_ru_description), findsNWidgets(2));

    await tapElement(tester, find.byWidgetPredicate((it) => it is SelectRailwayUndertakingInput));

    // select 3 RU
    await tapElement(tester, find.text(l10n.c_ru_sbb).first);
    await tapElement(tester, find.text(l10n.c_ru_bls_c).first);
    await tapElement(tester, find.text(l10n.c_ru_sob_t).first);

    await tapElement(
      tester,
      find.byWidgetPredicate(
        (it) => it is IconButton && it.icon is Icon && (it.icon as Icon).icon == SBBIcons.cross_small,
      ),
    );
    await tester.pumpAndSettle(Duration(seconds: 1));

    // check that selected RU are shown in profile
    final evuText = '${l10n.c_ru_sbb}, ${l10n.c_ru_bls_c}, ${l10n.c_ru_sob_t}';
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

    final evuText2 = '${l10n.c_ru_sbb}, ${l10n.c_ru_sob_t}';
    expect(find.text(evuText2), findsOneWidget);
  });

  testWidgets('test user tour system profile selection', (tester) async {
    await prepareAndStartApp(tester);
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

    // check initial RU is empty
    expect(find.text(l10n.w_user_tour_system_selection_label), findsNWidgets(2));

    await tapElement(tester, find.byWidgetPredicate((it) => it is SBBSelect));

    // Select tour system
    await tapElement(tester, find.text(l10n.c_tour_system_rail_cube).first);

    expect(find.text(l10n.c_tour_system_rail_cube), findsOne);

    await tapElement(tester, find.byWidgetPredicate((it) => it is SBBSelect));
    await tapElement(tester, find.text(l10n.c_tour_system_bls_ivu).first);

    expect(find.text(l10n.c_tour_system_bls_ivu), findsOne);
  });
}
