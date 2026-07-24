import 'package:app/pages/links/links_page.dart';
import 'package:app/widgets/railway_undertaking/widgets/select_railway_undertaking_input.dart';
import 'package:app/widgets/railway_undertaking/widgets/select_railway_undertaking_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('links page tests', () {
    testWidgets('externalLinks_whenNoRuSelected_thenShowsEmptyState', (tester) async {
      await IntegrationTestApp.start(tester);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_links_title));

      // Verify we are on the links page
      expect(find.byType(LinksPage), findsOneWidget);

      // Verify empty state is shown
      expect(find.text(l10n.p_links_no_content), findsOneWidget);

      // Verify no link items are shown
      expect(find.text('Bahnhofportal'), findsNothing);
      expect(find.text('V-APP'), findsNothing);
      expect(find.text('ESQ'), findsNothing);
    });

    testWidgets('externalLinks_whenRuSelectedInProfile_thenShowsLinks', (tester) async {
      await IntegrationTestApp.start(tester);

      // Navigate to Profile and select SBB CH
      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

      await tapElement(tester, find.byWidgetPredicate((it) => it is SelectRailwayUndertakingInput));

      // Search for SBB CH in the filter field and select it
      await enterText(tester, find.byKey(SelectRailwayUndertakingModal.filterFieldKey), l10n.c_ru_sbb_ch);
      await tapElement(tester, find.text(l10n.c_ru_sbb_ch).last);

      // Close the modal
      await tapElement(
        tester,
        find.byWidgetPredicate(
          (it) => it is IconButton && it.icon is Icon && (it.icon as Icon).icon == SBBIcons.cross_small,
        ),
      );
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Navigate to Links page
      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_links_title));

      // Verify links are displayed
      expect(find.byType(LinksPage), findsOneWidget);
      expect(find.text(l10n.p_links_no_content), findsNothing);
      expect(find.text('Bahnhofportal'), findsOneWidget);
      expect(find.text('V-APP'), findsOneWidget);
      expect(find.text('ESQ'), findsOneWidget);
    });

    testWidgets('externalLinks_whenRuSelectionChanges_thenUpdatesLinks', (tester) async {
      await IntegrationTestApp.start(tester);

      // Navigate to Profile and select DB
      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

      await tapElement(tester, find.byWidgetPredicate((it) => it is SelectRailwayUndertakingInput));

      // Search for DB in the filter field and select it
      await enterText(tester, find.byKey(SelectRailwayUndertakingModal.filterFieldKey), l10n.c_ru_db);
      await tapElement(tester, find.text(l10n.c_ru_db).last);

      // Close the modal
      await tapElement(
        tester,
        find.byWidgetPredicate(
          (it) => it is IconButton && it.icon is Icon && (it.icon as Icon).icon == SBBIcons.cross_small,
        ),
      );
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Navigate to Links page
      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_links_title));

      // Only ESQ should be visible (linked to company 1080)
      expect(find.text('Bahnhofportal'), findsNothing);
      expect(find.text('V-APP'), findsNothing);
      expect(find.text('ESQ'), findsOneWidget);
    });
  });
}
