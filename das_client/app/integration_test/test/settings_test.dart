import 'package:app/pages/settings/settings_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test show decisive gradient setting', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T9999M');
    await stopAutomaticAdvancement(tester);

    // check km, up and down gradients are shown
    expect(find.text('km'), findsOneWidget);
    expect(find.text('+'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);

    // Navigate to settings page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_settings_title));

    final gradientSwitchFinder = find.byKey(SettingsPage.decisiveGradientSwitchKey);
    var gradientSwitch = tester.widget(gradientSwitchFinder) as SBBSwitch;
    expect(gradientSwitch.value, true);

    // disable decisive gradient setting
    await tapElement(tester, find.text(l10n.p_settings_page_decisive_gradient_show_setting));

    // refresh switch
    gradientSwitch = tester.widget(gradientSwitchFinder) as SBBSwitch;
    expect(gradientSwitch.value, false);

    // Navigate back to fahrtinfo page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrtinfo_title));

    // check km is shown, up and down gradients are hidden
    expect(find.text('km'), findsOneWidget);
    expect(find.text('+'), findsNothing);
    expect(find.text('-'), findsNothing);

    await disconnect(tester);
  });

  testWidgets('test km header click when decisive gradient is not shown', (tester) async {
    await prepareAndStartApp(tester);

    // Navigate to settings page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_settings_title));

    // disable decisive gradient setting
    await tapElement(tester, find.text(l10n.p_settings_page_decisive_gradient_show_setting));

    // Navigate back to fahrtinfo page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrtinfo_title));

    await loadJourney(tester, trainNumber: 'T9999M');
    await stopAutomaticAdvancement(tester);

    // check km is shown, up and down gradients are hidden
    expect(find.text(l10n.p_journey_table_kilometre_label), findsOneWidget);
    expect(find.text('+'), findsNothing);
    expect(find.text('-'), findsNothing);

    // click on km header
    await tapElement(tester, find.text(l10n.p_journey_table_kilometre_label));

    // check km is hidden, up and down gradients are shown
    expect(find.text(l10n.p_journey_table_kilometre_label), findsNothing);
    expect(find.text('+'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);

    // click on gradient up header
    await tapElement(tester, find.text('+'));

    // check km is shown, up and down gradients are hidden
    expect(find.text(l10n.p_journey_table_kilometre_label), findsOneWidget);
    expect(find.text('+'), findsNothing);
    expect(find.text('-'), findsNothing);

    // click on km header
    await tapElement(tester, find.text(l10n.p_journey_table_kilometre_label));

    // check km is hidden, up and down gradients are shown
    expect(find.text(l10n.p_journey_table_kilometre_label), findsNothing);
    expect(find.text('+'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);

    // click on gradient down header
    await tapElement(tester, find.text('-'));

    // check km is shown, up and down gradients are hidden
    expect(find.text(l10n.p_journey_table_kilometre_label), findsOneWidget);
    expect(find.text('+'), findsNothing);
    expect(find.text('-'), findsNothing);

    // click on km header
    await tapElement(tester, find.text(l10n.p_journey_table_kilometre_label));

    // check revert back to km after delay
    await waitUntilExists(tester, find.text(l10n.p_journey_table_kilometre_label));

    await disconnect(tester);
  });
}
