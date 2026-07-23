import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_chevron.dart';
import 'package:app/pages/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('settings_whenDecisiveGradientDisabled_thenHidesGradients', (tester) async {
    await IntegrationTestApp.start(tester);
    await loadJourney(tester, trainNumber: 'T9999M');

    // check km, up and down gradients are shown
    expect(find.text('km'), findsOneWidget);
    expect(find.text('+'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);

    // Navigate to settings page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_settings_title));

    final gradientSwitchFinder = find.byKey(SettingsPage.decisiveGradientSwitchKey);
    var gradientSwitch = tester.widget(gradientSwitchFinder) as SBBSwitchListItemBoxed;
    expect(gradientSwitch.value, true);

    // disable decisive gradient setting
    await tapElement(tester, find.text(l10n.p_settings_page_decisive_gradient_show_setting));

    // refresh switch
    gradientSwitch = tester.widget(gradientSwitchFinder) as SBBSwitchListItemBoxed;
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

  testWidgets('settings_whenKmHeaderClickedWithGradientHidden_thenTogglesDisplay', (tester) async {
    await IntegrationTestApp.start(tester);

    // Navigate to settings page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_settings_title));

    // disable decisive gradient setting
    await tapElement(tester, find.text(l10n.p_settings_page_decisive_gradient_show_setting));

    // Navigate back to fahrtinfo page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrtinfo_title));

    await loadJourney(tester, trainNumber: 'T9999M');

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

  testWidgets('settings_whenStationSignalHidden_thenHidesCorrectSignals', (tester) async {
    await IntegrationTestApp.start(tester);
    await loadJourney(tester, trainNumber: 'T9999M');

    await stopAutomaticAdvancement(tester);

    final scrollableFinder = find.byType(AnimatedList);
    expect(scrollableFinder, findsOneWidget);

    // Check entry and exit signals are shown
    await tester.dragUntilVisible(find.text(l10n.c_main_signal_function_entry), scrollableFinder, const Offset(0, 50));
    expect(find.text(l10n.c_main_signal_function_entry), findsAny);
    await tester.dragUntilVisible(find.text(l10n.c_main_signal_function_exit), scrollableFinder, const Offset(0, 50));
    expect(find.text(l10n.c_main_signal_function_exit), findsAny);

    // Navigate to settings page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_settings_title));

    // disable decisive gradient setting
    await tapElement(tester, find.text(l10n.p_settings_page_signal_station_setting));

    // Navigate back to fahrtinfo page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrtinfo_title));

    // Check entry and exit signals no longer shown
    expect(find.text(l10n.c_main_signal_function_entry), findsNothing);
    expect(find.text(l10n.c_main_signal_function_exit), findsNothing);

    await disconnect(tester);
  });

  testWidgets('settings_whenStationSignalHidden_thenChevronPositionsCorrectly', (tester) async {
    await IntegrationTestApp.start(tester);

    // Navigate to settings page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_settings_title));

    // disable decisive gradient setting
    await tapElement(tester, find.text(l10n.p_settings_page_signal_station_setting));

    // Navigate back to fahrtinfo page
    await openDrawer(tester);
    await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrtinfo_title));

    await loadJourney(tester, trainNumber: 'T9999');

    // Check entry and exit signals no longer shown
    expect(find.text(l10n.c_main_signal_function_entry), findsNothing);
    expect(find.text(l10n.c_main_signal_function_exit), findsNothing);

    // Check chevron is positioning correctly
    await waitUntilExists(
      tester,
      find.descendant(of: findDASTableRowByText('0.5'), matching: find.byKey(RouteChevron.chevronKey)),
    );
    await waitUntilExists(
      tester,
      find.descendant(of: findDASTableRowByText('1.2'), matching: find.byKey(RouteChevron.chevronKey)),
    );
    await waitUntilExists(
      tester,
      find.descendant(of: findDASTableRowByText('2.4'), matching: find.byKey(RouteChevron.chevronKey)),
    );

    await disconnect(tester);
  });

  group('T45 nsp signals', () {
    testWidgets('settings_whenStationSignalsToggled_thenHidesButKeepsEtcsStopSigns', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T45');
      await stopAutomaticAdvancement(tester);

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // Station signals (entry/intermediate/track end) and ETCS stop signs are visible.
      await tester.dragUntilVisible(find.text('E1'), scrollableFinder, const Offset(0, -50));
      await tester.dragUntilVisible(find.text('AB1'), scrollableFinder, const Offset(0, -50));
      await tester.dragUntilVisible(find.text('ESS1'), scrollableFinder, const Offset(0, -50));
      await tester.dragUntilVisible(find.text('ESS2'), scrollableFinder, const Offset(0, -50));
      await tester.dragUntilVisible(find.text('ESS3'), scrollableFinder, const Offset(0, -50));
      await tester.dragUntilVisible(find.text('ESS3'), scrollableFinder, const Offset(0, -50));
      await tester.dragUntilVisible(find.text('TE1'), scrollableFinder, const Offset(0, -50));

      await _toggleSignalSwitch(tester, SettingsPage.stationSignalSwitchKey);

      // Station signals are gone, ETCS stop signs remain.
      expect(find.text('E1'), findsNothing);
      expect(find.text('AB1'), findsNothing);
      expect(find.text('AB2'), findsNothing);
      expect(find.text('TE1'), findsNothing);
      expect(find.text('ESS1'), findsAny);
      expect(find.text('ESS2'), findsAny);
      expect(find.text('ESS3'), findsAny);

      await disconnect(tester);
    });

    testWidgets('settings_whenEtcsConventionalToggled_thenHidesOnlyConventionalStopSign', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T45');
      await stopAutomaticAdvancement(tester);

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // All three ETCS stop signs are visible by default.
      await tester.dragUntilVisible(find.text('ESS1'), scrollableFinder, const Offset(0, -50));
      expect(find.text('ESS1'), findsAny);
      await tester.dragUntilVisible(find.text('ESS2'), scrollableFinder, const Offset(0, -50));
      expect(find.text('ESS2'), findsAny);
      await tester.dragUntilVisible(find.text('ESS3'), scrollableFinder, const Offset(0, -50));
      expect(find.text('ESS3'), findsAny);

      await _toggleSignalSwitch(tester, SettingsPage.ectsConventionalSpeedSignalSwitchKey);

      // ESS1 lives inside the conventional speed segment (1500m-2500m) → hidden.
      expect(find.text('ESS1'), findsNothing);
      await tester.dragUntilVisible(find.text('ESS2'), scrollableFinder, const Offset(0, -50));
      expect(find.text('ESS2'), findsAny);
      await tester.dragUntilVisible(find.text('ESS3'), scrollableFinder, const Offset(0, -50));
      expect(find.text('ESS3'), findsAny);

      // Station signals are unaffected.
      await tester.dragUntilVisible(find.text('E1'), scrollableFinder, const Offset(0, 50));
      expect(find.text('E1'), findsAny);

      await disconnect(tester);
    });

    testWidgets('settings_whenEtcsExtendedToggled_thenHidesOnlyExtendedStopSigns', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T45');
      await stopAutomaticAdvancement(tester);

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // All three ETCS stop signs are visible by default.
      await tester.dragUntilVisible(find.text('ESS1'), scrollableFinder, const Offset(0, -50));
      expect(find.text('ESS1'), findsAny);
      await tester.dragUntilVisible(find.text('ESS2'), scrollableFinder, const Offset(0, -50));
      expect(find.text('ESS2'), findsAny);
      await tester.dragUntilVisible(find.text('ESS3'), scrollableFinder, const Offset(0, -50));
      expect(find.text('ESS3'), findsAny);

      await _toggleSignalSwitch(tester, SettingsPage.ectsExtendedSpeedSignalSwitchKey);

      // ESS2 (extSpeedReversingImpossible 2500-3000m) and ESS3 (extSpeedReversingPossible 3000-3499m) are hidden.
      expect(find.text('ESS2'), findsNothing);
      expect(find.text('ESS3'), findsNothing);

      // ESS1 (conventional) remains.
      expect(find.text('ESS1'), findsAny);

      // Station signals stay untouched.
      expect(find.text('E1'), findsAny);
      expect(find.text('AB2'), findsAny);

      await disconnect(tester);
    });

    testWidgets('settings_whenBothEtcsToggledOff_thenHidesAllEtcsStopSigns', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T45');
      await stopAutomaticAdvancement(tester);

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      await _toggleSignalSwitch(tester, SettingsPage.ectsConventionalSpeedSignalSwitchKey);
      await _toggleSignalSwitch(tester, SettingsPage.ectsExtendedSpeedSignalSwitchKey);

      // All ETCS stop signs are hidden.
      expect(find.text('ESS1'), findsNothing);
      expect(find.text('ESS2'), findsNothing);
      expect(find.text('ESS3'), findsNothing);

      // Station signals remain visible.
      expect(find.text('E1'), findsAny);
      expect(find.text('AB1'), findsAny);

      await disconnect(tester);
    });
  });
}

/// Opens settings, toggles the switch identified by [switchKey] and returns to the journey screen.
Future<void> _toggleSignalSwitch(WidgetTester tester, Key switchKey) async {
  await openDrawer(tester);
  await tapElement(tester, find.text(l10n.w_navigation_drawer_settings_title));

  final switchFinder = find.byKey(switchKey);
  expect(switchFinder, findsOneWidget);
  await tester.ensureVisible(switchFinder);
  await tapElement(tester, switchFinder);

  await openDrawer(tester);
  await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrtinfo_title));
}
