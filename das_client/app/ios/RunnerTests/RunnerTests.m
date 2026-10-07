@import XCTest;
@import integration_test;
@import ObjectiveC.runtime;

// One entry per Flutter test. Generate this list the same way the current
// generator produces the test methods.
static NSArray<NSString *> *RunnerDartTestNames(void) {
  return @[
      //GENERATED CODE
      @"testAsrModalWhenModalOpenedThenHidesTimeColumnP7ydFbghPvgMoyaSfNjFTests1219", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAsrModalWhenMissingOptionalFieldsThenShowsDashesDJrbXirX37Dq6cvL1nLxTests567", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAsrModalWhenAllDetailsPresentThenShowsAllDetails0eQJ41IWn8ueyne4Nzh2Tests567", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAsrModalWhenSameRowTappedTwiceThenClosesModalPJoSYPI4xQRZFe8UsGTdTests1875", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAsrModalWhenRadioChannelTappedWhileOpenThenSwitchesWithoutClosingFYCL15anxOtsmYgvuzl3Tests1875", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAsrModalWhenNonInteractiveAreaTappedThenClosesModalJajHl07W13dG4g0wsctjTests1875", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAsrModalWhenComplexAsrWithMultipleEntriesThenShowsAllEntries4dhyrq0I6dm7WCcmpMDRTests227", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAppExpirationWhenExpiresSoonThenShowsDismissibleDialogOnceWdTKidFSmgo3zr9DWxHHTests245", // integration_test/test/app_expiration_test.dart
      @"testAppExpirationWhenExpiredThenShowsNonDismissibleDialogRppcazq2UO5W3xR0IZLGTests245", // integration_test/test/app_expiration_test.dart
      @"testAppLinkWhenLinkWithSingleTrainOpensJourneyN2DspgYQ3KU5M4zWXh7QTests97", // integration_test/test/app_link_test.dart
      @"testAppLinkWhenLinkWithMultipleTrainsOpensFirstJourneyAndRestInNavigationFvyLq39APcu9HXYDxOReTests97", // integration_test/test/app_link_test.dart
      @"testAppLinkWhenLinkWithValidAndUnknownTrainOpensFirstJourneyAndShowsErrorPageForSecondPekbdz3nHeeVcICqD6wYTests97", // integration_test/test/app_link_test.dart
      @"testAppLinkWhenLinkWhileUnauthenticatedOpensJourneyAfterLoginFlowAZdIaGI51vKrPz2ShZnRTests97", // integration_test/test/app_link_test.dart
      @"testAppLinkWhenLinkWithUnknownTrainShowsErrorPage15g1jT1sZm8j2GSw3mbsTests97", // integration_test/test/app_link_test.dart
      @"testAppLinkWhenLinkWithTafTapStartAndEndShowsTrainDriverTurnoverRowsTLIAIKurErFTRsyXwV1STests296", // integration_test/test/app_link_test.dart
      @"testAppLinkWhenLinkWithReturnUrlShouldUseReturnUrlOverDefaultTourSystemUrlB6vkX9lfHGRkIzsZ1us6Tests9796", // integration_test/test/app_link_test.dart
      @"testAppLinkWhenAlreadyOnJourneyPageReceivingDeeplinkOpensNewJourneyRWOQbfY4K3XnuDZ0sdXOTests1852", // integration_test/test/app_link_test.dart
      @"testAppLinkWhenLinkWithSingleTrainShowsCompanyMatchSelectionWRCsXpxpYvtJofkQoFYNTests702", // integration_test/test/app_link_test.dart
      @"testAppLinkWhenAlreadyOnJourneyPageReceivingDeeplinkOpensSelectionWithCompanyMatchMSFNFsBOiBB94sxZptbDTests702", // integration_test/test/app_link_test.dart
      @"testAppLinkWhenAlreadyOnJourneyPageReceivingDeeplinkOpensNewJourneyWithMatchingRu3rMlQu5RKMLbWnkW3HAtTests702", // integration_test/test/app_link_test.dart
      @"testAutomaticAdvancementWhenJourneyLoadedThenScrollsAutomaticallyZGzAbCSbv7PPJgvNDu2MTests94", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticAdvancementWhenIdleTimeReachedThenScrollsBackToPosition78V0rplxI8A6LGzwHf3RTests94", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticAdvancementWhenTableIsTappedThenIdleTimeIsNotResetO2JzoXIvpJXPp5KP71BtTests1923", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticAdvancementWhenTableIsScrolledThenIdleTimeIsResetCwg37CLdZA4TygXWeEUsTests192394", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticAdvancementWhenReEnabledThenScrollsToCurrentPosition4Ia2ip74kN6FpYMEnx80Tests94", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticAdvancementWhenDisabledThenDoesNotScroll4JEbtNRJ2FHdV4Ab1fx9Tests94", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticAdvancementWhenJourneyLoadedThenIsEnabledByDefaultQOLT57vft3usf96YbYjATests94", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticAdvancementWhenDisabledThenShowsStickyFooter2UNRYR5awQHQMmyn9QaeTests94", // integration_test/test/automatic_advancement_test.dart
      @"testTimedAdvancementWhenJourneyLoadedThenAdvancesCorrectly6VsC8w1YfGUW4CkTbX7QTests1419", // integration_test/test/automatic_advancement_test.dart
      @"testTimedAdvancementWhenJourneyLoadedThenAdvancesByOperationalAndPlannedTimesKp3WqzT9rLxYhNv2QmDeTests939", // integration_test/test/automatic_advancement_test.dart
      @"testTimedAdvancementWhenSignaledPositionBehindAndPunctualityHiddenThenSignalWinsXw7RtLm2QpKvYc9HbNd3Tests2491", // integration_test/test/automatic_advancement_test.dart
      @"testBrakeSlipWhenPositionUpdateWhileBrakeSlipPageOpenThenDoesNotUpdateToNewPositionLqq9jBQeZXKwYjM3vWYFTests1605", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipWhenNoDataAvailableThenDoesNotShowButton4z9DtXCNPqahGoefcXqOTests692568", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipWhenFormationDataLoadedThenShowsInformationAndNavigationLTuJGUbeVyBkXBp0mWCSTests692", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipWhenBrakeDetailsFeatureEnabledThenShowsBrakeDetailsUSAIOF7ht1RLvSOPKHb6Tests2641", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipWhenBrakeDetailsFeatureDisabledThenHidesBrakeDetailsOtnw80xp0sracqUJLFCJTests2641", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipWhenSpecialIndicatorsArePresentThenShowsBannersYgF4hHe8Cl7C98NaC5xjTests692", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipWhenDifferentBrakeSeriesInFormationThenShowsNotificationNFIIta4nBxJ20VkGCgH0Tests692", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipModalWhenOpenedThenDisplaysCorrectInformationLxpggIMjzbU9W3aoNNeWTests692568", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipModalWhenIdleTimeoutElapsesThenNeverClosesAutomatically1g0A50LfMqOsfFqkWrkJTests1867", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipModalWhenButtonTappedWhileOpenThenClosesModal7VngjKboIfqc2qmsEuwsTests1875", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipModalWhenNonInteractiveAreaTappedThenClosesModal4u1bk9VV17S4h9RpUQxmTests1875", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipModalWhenFullscreenButtonTappedThenOpensFullscreenSLTLSnINc1xWV6Sv6gVKTests692", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipWhenFormationUpdatedThenShowsNotificationHt9hpOZmHcaTZUyQb4RfTests695", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipWhenFormationRunChangedThenUpdatesRunChangeDisplayIG1dyvhq8hUk2uhyOMOJTests694", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeSlipWhenTransportDocumentsAreConfiguredThenButtonVisibilityAndLaunchBehaviorMatchFormationDataK2dX0Vd8r1sZ9fQm7uJmTests1620", // integration_test/test/brake_load_slip_test.dart
      @"testChronographWhenNoUpdatesThenHidesPunctualityDisplayRHuNlE41ENvoE7vZK3UpTests300", // integration_test/test/chronograph_test.dart
      @"testChronographWhenNoUpdatesThenPunctualityBecomesStale1W4NytAMRiJrry9NzJJ0Tests300", // integration_test/test/chronograph_test.dart
      @"testChronographWhenPunctualityUpdateReceivedThenDisplaysCorrectlyCA2h5q5rFvVIvZjoCL9iTests300", // integration_test/test/chronograph_test.dart
      @"testChronographWhenNoCalculatedSpeedAndNoPlannedTimesThenHidesPunctuality8bo2dGfbGlmQVHT7mRlBTests19692257", // integration_test/test/chronograph_test.dart
      @"testChronographWhenNoSferaDelayAvailableThenShowsPlannedTimeDeviationIXKTMP5ojTtZd7Eo7VF5Tests1851", // integration_test/test/chronograph_test.dart
      @"testChronographWhenPlannedTimeDeviationFeatureDisabledThenNeverShowsDeviationIk64KpZ9j4qN3klSOCkBTests1851", // integration_test/test/chronograph_test.dart
      @"testChronographWhenJourneyLoadedThenShowsCorrectCurrentTimeXVdCWlyYq41HhAr9p2hmTests79", // integration_test/test/chronograph_test.dart
      @"testCloseJourneyWhenTrainNotInMotionThenClosesWithoutConfirmationOzoPj2dv77YjMngGFB3LTests2219", // integration_test/test/close_journey_test.dart
      @"testCloseJourneyWhenTrainInMotionAndDismissedThenStaysOnJourneyL0SDAY1hfFdW8kZ5W4uqTests2219", // integration_test/test/close_journey_test.dart
      @"testCloseJourneyWhenTrainInMotionAndConfirmedThenClosesJourneyMQdAITcqlVtmatYUWwJJTests2219", // integration_test/test/close_journey_test.dart
      @"testJourneySearchOverlayWhenOpenedThenShowsNoConfirmationImAMqzaTvhzQ6pWsFWPxTests2219", // integration_test/test/close_journey_test.dart
      @"testJourneySearchOverlayWhenNewTrainLoadedAndDismissedThenStaysOnJourneyLK3zLOfV6lNG08NYVwB2Tests2219", // integration_test/test/close_journey_test.dart
      @"testJourneySearchOverlayWhenDifferentTrainLoadedAndConfirmedThenLoadsOtherJourney8b0DxFQyhlwo6oCv6TQwTests2219", // integration_test/test/close_journey_test.dart
      @"testDepartureProcessWhenFeatureEnabledThenChecklistButtonDisplayedCorrectlyNW7qkKijklYmLt0yngJ6Tests627", // integration_test/test/departure_process_test.dart
      @"testDepartureProcessWhenNoCustomerOrientedDepartureThenChecklistButtonOpensDepartureDialogLwlj8frlqY7pBq76LGKuTests627", // integration_test/test/departure_process_test.dart
      @"testDepartureProcessWhenFeatureEnabledThenShowsChronographWarningNqR5G6rO4Aw4aeZLyZL4Tests627", // integration_test/test/departure_process_test.dart
      @"testExternalLinksWhenNoCompanySelectedThenShowsEmptyStateYWizuavbVmWzQn5OoqIETests147", // integration_test/test/external_links_test.dart
      @"testExternalLinksWhenCompanySelectedInSettingsPageThenShowsCorrectLinksVNfgpqG3Ma8VUpXenmkYTests147", // integration_test/test/external_links_test.dart
      @"testExternalLinksWhenCompanySelectionChangesThenUpdatesLinksMzF1gipYtU39GeQHCZcATests147", // integration_test/test/external_links_test.dart
      @"testCustomerOrientedDepartureWhenStatusChangesThenDisplaysNotificationsCorrectlyDIW8ooYfMKINdzpGCp4STests148", // integration_test/test/journey_customer_oriented_departure_test.dart
      @"testCustomerOrientedDepartureWhenJourneyChangesThenSubscriptionUpdates7cmV7s3vxPmsKqjVUcXDTests148", // integration_test/test/journey_customer_oriented_departure_test.dart
      @"testJourneyHeaderWhenConnectivityChangesThenShowsCorrectStateINnxRgqXwEq3DKjj5xkoTests119", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenJourneyLoadedThenTurnsOnAlwaysOnDisplayWxr40hIhESiOEWYDJTeDTests591", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenJourneyClosedThenTurnsOffAlwaysOnDisplay85sJ2C4mLMJHgOJ8qZCXTests591", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenTrainActiveThenHidesAppBarY8vN9CR9fYwhIrxBzq68Tests79670", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenThemeSwitchTappedThenSwitchesThemeZhLtX4wiqLsmQxd537psTests102", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenExtendedMenuOpenedThenShowsCloseButton3ND51AAMNM7zIQ6jQuJsTests497", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenManeuverModeToggledThenShowsNotificationCnrguVzWD6cZ1wJtRpnmTests242", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenManeuverNotificationSwitchTappedThenHidesNotificationXqiXbNFDNL2YEEEGdMMTTests242", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenWaraAppInstalledAndManeuverModeThenShowsWaraAppLinkMFGC6WM2ZhGAvZOru19zTests242", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenWarnappDisabledThenHidesManeuverModeTWnozeOhBpZvpfl5l5ttTests242445", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenWaraAppInstalledThenShowsOpenMenuItemBC5tOxJbc31r6u4oe66LTests242", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenBatteryAbove15PercentThenHidesIcon5Ehxse0aAny05PMaCF9GTests123", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenBatteryBelow15PercentThenShowsIconAndModalEm5ecUdyqo96tv29cg28Tests123590", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenCommunicationNetworkChangesThenDisplaysCorrectlyC3iKkuijMLoz0xz3gSPtTests125", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenRadioContactsChangeThenDisplaysCorrectlyTr4Sky5hk17bxb622pSTTests125", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenDoubleTappedThenSetsBrightnessToZeroO8gneDOXV3qSXnyNiMPKTests101", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenDraggedRightThenIncreasesBrightnessDsETQyDLocUSGSQfMnmtTests101", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenDraggedLeftThenDecreasesBrightnessVENb2YZWboKuRpbZfdSWTests101", // integration_test/test/journey_header_test.dart
      @"testJourneyHeaderWhenDepartureAuthorizationPresentThenDisplaysCorrectly1kg0KDpUjd6nDMn4q7C6Tests226", // integration_test/test/journey_header_test.dart
      @"testNotificationWhenDepartureProcessDialogOpenedThenDisplaysCorrectlyT2Ga4z72ZhW01N8DYa7MTests624627", // integration_test/test/journey_notification_test.dart
      @"testNotificationWhenDisturbanceOccursThenShowsAndHidesNotificationM1OE34O4n52uYYiRVMU2Tests244", // integration_test/test/journey_notification_test.dart
      @"testNotificationWhenDepartureDispatchReceivedThenDisplaysCorrectlyXgZckSB39KkesylhsvYwTests124", // integration_test/test/journey_notification_test.dart
      @"testNotificationWhenMultipleNotificationsThenPrioritizesCorrectlyJ6oFf00OSzO3qQY0XdQmTests1402", // integration_test/test/journey_notification_test.dart
      @"testNotificationWhenReauthenticationRequiredThenShowsNotificationJvUwuJ6r5MeLK0dpaaUWTests1320", // integration_test/test/journey_notification_test.dart
      @"testReplacementSeriesWhenSuggestedThenSelectsAndReturnsToOriginalMM0ytFua6PYMSusJG4TrTests507", // integration_test/test/journey_replacement_series_test.dart
      @"testReplacementSeriesWhenNoReplacementAvailableThenDoesNotSuggestUlgXunAeOxDqNsbksvyiTests507", // integration_test/test/journey_replacement_series_test.dart
      @"testReplacementSeriesWhenEndOfSegmentReachedThenMessageDisappearsLIzLPYFFXgBTt95ZmBIRTests507", // integration_test/test/journey_replacement_series_test.dart
      @"testReplacementSeriesWhenNoReplacementForBrakeSeriesThenShowsNotificationNVOhVZ4DmLz4SAnArtplTests938", // integration_test/test/journey_replacement_series_test.dart
      @"testJourneySearchOverlayWhenOpenedAndDismissedThenTogglesCorrectlyHjtzMqmAjVVBOfkjFxJiTests456", // integration_test/test/journey_search_overlay_test.dart
      @"testJourneySearchOverlayWhenOpenedThenShowsDefaultsAndValidation7pJRXknm1Dj2sOExzEtoTests456", // integration_test/test/journey_search_overlay_test.dart
      @"testJourneySearchOverlayWhenTrainLoadedThenOpensJourneyWithoutNavigationButtonsPfFjIKgB8Rju5BAkp7S1Tests456", // integration_test/test/journey_search_overlay_test.dart
      @"testJourneySearchOverlayWhenMultipleCompanyMatchesThenRedirectsToSelectionScreen78G6WgAFp4dv86tsGl14Tests702", // integration_test/test/journey_search_overlay_test.dart
      @"testAdditionalSpeedRestrictionWhenRowDisplayedThenShowsCorrectlyH60HiYVcM6InpQTWSsDiTests87", // integration_test/test/journey_table_additional_speed_restriction_test.dart
      @"testAdditionalSpeedRestrictionWhenNonAsrRowsBetweenThenColorsCorrectlyYA4sSmXtTNzic4SCKmRCTests87", // integration_test/test/journey_table_additional_speed_restriction_test.dart
      @"testAdditionalSpeedRestrictionWhenComplexAsrThenDisplaysCorrectlyPe2ToyhUi8oW7PKpElj7Tests227", // integration_test/test/journey_table_additional_speed_restriction_test.dart
      @"testAdditionalSpeedRestrictionWhenOnEtcsLevel2SectionThenDisplaysCorrectlyX08STS2QuB7Tn1u8HHnYTests120", // integration_test/test/journey_table_additional_speed_restriction_test.dart
      @"testAdditionalSpeedRestrictionWhenSequentialAsrThenDisplaysCorrectlyJsCo6tECyuHPKcZMZRxETests566", // integration_test/test/journey_table_additional_speed_restriction_test.dart
      @"testAdvisedSpeedWhenNotificationReceivedThenDisplaysCorrectlyDifsm3d1efVsKjn1IJjjTests22812851306", // integration_test/test/journey_table_advised_speeds_test.dart
      @"testAdvisedSpeedWhenJourneyLoadedThenDisplaysCorrectly85DIebkYiATNR4kWtS5cTests22812851306", // integration_test/test/journey_table_advised_speeds_test.dart
      @"testBaliseLevelCrossingWhenMultipleLevelCrossingsThenDisplaysCorrectlyB4vSeswDglqaMsxgpZPETests2241416", // integration_test/test/journey_table_balise_level_crossing_test.dart
      @"testBaliseLevelCrossingWhenGroupTappedThenExpandsAndCollapsesAwz0LEkHyRCsE2VMTXprTests2241416454", // integration_test/test/journey_table_balise_level_crossing_test.dart
      @"testBaliseLevelCrossingWhenInEtcsLevel2SectionThenDisplaysCorrectlyX6KeDRPFfrKsZlGfYgTMTests14291416224", // integration_test/test/journey_table_balise_level_crossing_test.dart
      @"testBrakeSeriesWhenDefaultMissingThenShowsQuestionMarksE3YDk2VuPDFkNZxENqh1Tests89", // integration_test/test/journey_table_brake_series_test.dart
      @"testBrakeSeriesWhenDefaultFromTrainCharacteristicsThenShowsR1158coWWI2zvgkHncg31PgpTests89", // integration_test/test/journey_table_brake_series_test.dart
      @"testBrakeSeriesWhenOpenedThenShowsAllOptions8iPNeVrZhcbzOth6Ao2KTests89", // integration_test/test/journey_table_brake_series_test.dart
      @"testBrakeSeriesWhenNoBrakeSeriesDefinedThenShowsMessageNzj1s9oCEioBI3FtabVRTests89", // integration_test/test/journey_table_brake_series_test.dart
      @"testCalculatedSpeedWhenJourneyLoadedThenDisplaysCorrectlyMfGgJRQKClLfSpfi6maOTests88367", // integration_test/test/journey_table_calculated_speed_test.dart
      @"testCalculatedSpeedWhenDisplayedInStickyHeaderThenShowsCorrectlyYx1uKcECluWqDNFyQ6zRTests88367", // integration_test/test/journey_table_calculated_speed_test.dart
      @"testCalculatedSpeedWhenNoVproSpeedAtPositionThenHidesPunctualityDlsoheuAER1XBsYUmjNTTests88122", // integration_test/test/journey_table_calculated_speed_test.dart
      @"testCalculatedSpeedWhenReducedToLineSpeedThenDisplaysInDifferentColorMk8PekT17HLJlrLqXMz9Tests88367", // integration_test/test/journey_table_calculated_speed_test.dart
      @"testCollapsibleRowsWhenOperationalIndicationDisplayedThenCollapsesIaCfo6CRqrax4porwjuBTests126", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsibleRowsWhenRadnFootNoteDisplayedThenCollapsesClmYSuxH6dOypT2xgln8Tests625", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsibleRowsWhenLongTextPresentThenShowsMoreButtonLEGwTOYFxWLauMjiWDDMTests126", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsibleRowsWhenCombinedIndicationsThenReplacesNewLinesWithDelimiterWn0E9HeXjfz8Lk3XEgvaTests126625", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsibleRowsWhenSameServicePointThenCombinesIndicationAndFootNotePkZjtPxXkInflC3IIs74Tests126625", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsibleRowsWhenOperationalIndicationPassedThenCollapsesH9JLGRVgfPYcsgEwWMyXTests126", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsibleRowsWhenRadnFootNotePassedThenCollapsesSLbIwzyEcCfKwY77CQRzTests625", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsibleRowsWhenRadnFootNoteDisplayedThenTitleContainsType8XcuHwPmJI1ijGizGFsDTests625", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testSimFootNoteWhenNonSimTrainThenSimFootNoteIsCollapsedGnYPge8jjpnKHq6CbSm1Tests1126", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testSimFootNoteWhenSimTrainThenSimFootNoteIsExpandedAndNotCollapsedWhenPassedWGzkdPjTfFUKkJKNw92kTests1126", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsibleRowsWhenMovingBackwardsThenResetRowsToDefaultSate60quLbjUFK7kIPulz6LbTests1617", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsibleRowsWhenLineFootNoteRepeatedThenRepetitionsAreCollapsedByDefault156zLPEeDK5CzaN0BPcMTests2219", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsibleRowsWhenMovingBackwardsThenLineFootNotesAreResetToTheirDefaultN1p736TbYkrBbZ4IoM2XTests2219", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testStationPropertyWhenStationSignsPresentThenDisplaysCorrectly33p6hQftZIHPSWXIQyMFTests127", // integration_test/test/journey_table_station_property_test.dart
      @"testStationPropertyWhenPropertiesPresentThenDisplaysCorrectly2048M4EI2XWF3xp9fNzrTests127", // integration_test/test/journey_table_station_property_test.dart
      @"testStationPropertyWhenTrainSeriesChangesThenUpdatesDisplay6yG8VYvMt02JOmuS9rDcTests127", // integration_test/test/journey_table_station_property_test.dart
      @"testJourneyTableWhenCurvesPresentThenDisplaysEndOfCurvesCorrectlyGfSq5x3EgvhqDIZFmdAmTests478", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenSummarizedCurveThenDisplaysAsOneFSNNJU7cWww3zx7ZXrfQTests584", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenKilometerAndNetworkChangesThenDisplaysCorrectly4r5G55qZyLCbrPp8bWycTests1251237356", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenGradientPresentThenDisplaysUpAndDownhillWIvYo0q3NNOWuWNkvM28Tests225", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenBrakeSeriesA50ChosenThenFindsTwoCurves6dftwLIxISwNWPYqIBJjTests478584", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenBrakeSeriesR115ChosenThenFindsThreeCurvesGa09YBxY1Saxs4sdpFKqTests478584", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenWhistleAndTramAreaThenDisplaysCorrectlyUsmLmc9mBo7nGo9cREC8Tests224", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenChevronInGroupedItemsThenPositionsCorrectlyJoe81l2AczCXfgNHasnYTests94", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenDefaultBrakeSeriesThenShowsCorrectSpeedValues8X1ka8Bgi8yzoh4UjFZaTests89", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenMissingBrakeSeriesThenShowsCorrectSpeedValuesLLhbvIweHYZFneDKofeeTests89", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenConnectionTrackAndZahnstangePresentThenDisplaysCorrectlyUk1rmjXg0jCGsI5AReThTests136", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenLoadedThenShowsAllColumnsWithHeaders2xKQZqkInzVQYxlvy6h4Tests79", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenRoutePresentThenDisplaysCorrectlyRyZ21eZspmXAa5nGYdJJTests801557", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenProtectionSectionsPresentThenDisplaysCorrectlyHW5ShUks9dJRe4ik706zTests223", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenBothKilometresPresentThenDisplaysBothGXhdMHah4bTjsxlsQHccTests1863", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenBracketStationsThenDisplaysCorrectlyR7bVEtXlOIs8nat7DgNvTests81", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenHaltOnRequestThenDisplaysCorrectlySVXw9sGr7XUI7ZbBeRSZTests81", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenHaltPresentThenDisplaysItalicPsvC3EAHHTI7mNl15VLnTests81", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenServicePointHasTrackGroupThenDisplaysCorrectlyWithDetailModalGObFVFt2aAyPWMXp9cENTests1072", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenCurvesPresentThenDisplaysCurvesCorrectlyPNcLWjDBIMF8IuMwaXueTests82", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenSignalsPresentThenDisplaysCorrectly17wDIW5HykO2IvvtiOBpTests82", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenStationSpeedsThenDisplaysCorrectlyFXMX5vrKhaFEGsmWH1G5Tests82", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenLineSpeedThenAlwaysDisplaysInStickyHeaderJD3NqcaIve8Ivy8cnAWmTests932", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenEtcsLevel2SectionThenHidesLineSpeed3qRWUMgq0aQM4HAXpNjlTests120", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenAdditionalServicePointsThenDisplaysCorrectlyIfROK0ce5yyXlNxw2CzBTests258", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenShuntingMovementThenDisplaysMarkersCorrectly1hJ3sN82MojHdBszhwuDTests264", // integration_test/test/journey_table_test.dart
      @"testJourneyTableWhenMultipleColorsThenDisplaysCorrectPriorityBedMotS6Ncw5XayVseo6Tests1125", // integration_test/test/journey_table_test.dart
      @"testTimeCellWhenFixedPointRelevanceDisplayCorrectIcons3lGb8LE756LixsOVIyG8Tests1201", // integration_test/test/journey_table_time_test.dart
      @"testTimeCellWhenFarFutureJourneyThenShowsPlannedTimesOnly8vwuVlLyxynaCMpOv6jxTests84", // integration_test/test/journey_table_time_test.dart
      @"testTimeCellWhenNearFutureJourneyThenShowsOperationalAndPlannedTimesNx7aWInXVPGmH5bqoxmGTests84", // integration_test/test/journey_table_time_test.dart
      @"testTimeCellWhenManuallySetToPlannedThenAutoSwitchesBackToOperationalZJeVf25WtmGJFcMNAGNFTests84", // integration_test/test/journey_table_time_test.dart
      @"testTimeCellWhenDepartureTimeReachedThenUnderlinesTime9EQAkYvdXrJ4e7fZH6AeTests259", // integration_test/test/journey_table_time_test.dart
      @"testTrackEquipmentWhenCabSignalingThenDisplaysCorrectlyDNu1aGjJOxuHG1ka8zHSTests82", // integration_test/test/journey_table_track_equipment_test.dart
      @"testTrackEquipmentWhenLoadedThenDisplaysCorrectlyYUBlApq3Bgd4bwgvHGoJTests82", // integration_test/test/journey_table_track_equipment_test.dart
      @"testTrackEquipmentWhenSingleTrackNoBlockThenDisplaysCorrectlyUvRMEube4z8gQXU9Zw3bTests230", // integration_test/test/journey_table_track_equipment_test.dart
      @"testJourneyUpdatesWhenChangesReceivedThenDisplaysCorrectlyRCW5QKoQdUwtfxVEEIHRTests241", // integration_test/test/journey_table_updates_test.dart
      @"testJourneyUpdatesWhenModificationsAcknowledgedThenHandlesAcknowledgeUndoAndVisibilityQcfAfzgvqun2EA6aOH8ZTests2218", // integration_test/test/journey_table_updates_test.dart
      @"testJourneyUpdatesWhenTrainCharacteristicsUpdatedThenIgnoresUpdateLd7g7OsSEKkPbbGjJ5aMTests1416", // integration_test/test/journey_table_updates_test.dart
      @"testJourneyValidationWhenActivatedThenAllowsMultipleBrakeSeriesSelectionAndDisplaysX0mynzY28I2IJmP07sSbTests2734", // integration_test/test/journey_validation_test.dart
      @"testLoginWhenLogoutDialogIsDismissedThenIsStillLoggedInQRCD5Jy91TVe7KucfsQ7Tests1870", // integration_test/test/login_test.dart
      @"testLoginWhenStartedDefaultForIntegrationTestThenIsConnectedToMockBrokerO1tTzfXvce93K82ZFcob", // integration_test/test/login_test.dart
      @"testLoginWhenLogoutThenDefaultSelectionIsTmsVadOnLoginPageMgPV1riT2X8BFRJXjhSDTests2399", // integration_test/test/login_test.dart
      @"testLoginWhenLogoutThenLoginThenWillConnectToTmsVadVeZt1c1nxqKljOKbjk7QTests2399", // integration_test/test/login_test.dart
      @"testLoginWhenLogoutThenLoginWithSferaMockToggledThenWillConnectToSferaMockUcMtHMlV4XgL5Dw8BDeOTests2399", // integration_test/test/login_test.dart
      @"testManualAdvancementWhenServicePointDraggedThenJourneyPositionMovedIU0xYWTQ0mGPaNeRDOU9Tests741", // integration_test/test/manual_advancement_test.dart
      @"testManualAdvancementWhenManualPositionSetThenManualModeActivatedUntilJourneyPositionSignaledVF1BuwAJ8oK5QJ9NSrvzTests741", // integration_test/test/manual_advancement_test.dart
      @"testManualAdvancementWhenManualPositionSetThenStartTimedAdvancementQidAQQpf9ZctfYvUrotnTests1314", // integration_test/test/manual_advancement_test.dart
      @"testManualAdvancementWhenManualPositionSetThenRestartsPositionTimersTvZbKb7A7zMsILORpP0OTests1314", // integration_test/test/manual_advancement_test.dart
      @"testManualAdvancementWhenManualPositionSetThenShowsChevronAnimationColorRdLRFyaR0jBcplaGyVb1Tests1617", // integration_test/test/manual_advancement_test.dart
      @"testNavigationWhenDrawerOpenedThenShowsAllNavigationItems4zq12yxOhYBVFfmmbRMuTests80", // integration_test/test/navigation_test.dart
      @"testNavigationWhenLinksSelectedThenShowsLinksPage6ud9ZVIyRAaLfwadmi7bTests80", // integration_test/test/navigation_test.dart
      @"testNavigationWhenSettingsSelectedThenShowsSettingsPageNSe6ERbY0uoKIFbulzBATests80", // integration_test/test/navigation_test.dart
      @"testNavigationWhenSupportSelectedThenShowsSupportPageUwGtLIS6brDbdk4shRWJTests80", // integration_test/test/navigation_test.dart
      @"testNavigationWhenJourneySelectionPageSelectedThenShowsSelectionPageF5AHhw7WFEXFVWdrzZH6Tests80", // integration_test/test/navigation_test.dart
      @"testNavigationWhenNavigatingBackToJourneyThenJourneyStaysLoadedTVSAOe6GbJ5bWoqPD2v1Tests801557", // integration_test/test/navigation_test.dart
      @"testNavigationWhenNavigatingBackThenJourneySettingsNotResetRijOj3T18mvGVZNMrmTqTests80583811", // integration_test/test/navigation_test.dart
      @"testPersonalNotesWhenCreateThenUpdateNoteThenUpdatesModal1VehH7uMXywgKQOOzOICTests1009", // integration_test/test/personal_notes_test.dart
      @"testPersonalNotesWhenExistingSingleUseAndGeneralAndDeleteAfterwardsThenShowsSingleUseThenGeneralThenNothing4uZZWz3SWW0IYo7oidAJTests1009", // integration_test/test/personal_notes_test.dart
      @"testPersonalNotesWhenCreateNoteAsFootNoteThenDeleteThenUpdatesJourneyTable3ZCteqwJAfzRLMjae4uyTests1009", // integration_test/test/personal_notes_test.dart
      @"testPersonalNotesWhenCreateSingleUseNoteThenOnlyShowsInCurrentJourneyUBhcHMmWcVTq6qejZjrJTests1009", // integration_test/test/personal_notes_test.dart
      @"testPreloadWhenStatusChangesThenDisplaysCorrectlyVzryoGxMwq20YJrAmwSNTests90", // integration_test/test/preload_test.dart
      @"testPreloadWhenUsingPreloadDataThenReconnectsSuccessfullyNW5bzK5BHRo3TbUA6KWOTests90", // integration_test/test/preload_test.dart
      @"testReducedJourneyWhenNetworkChangePresentThenDisplaysWithKmBG8f0zcWS1hA8UmHb6XJTests356", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedJourneyWhenLoadedThenDisplaysTrainInformationVAiBsV3JAXE2ISLmbuphTests626", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedJourneyWhenShuntingMovementJourneyThenDisplaysTrainInformationHrT2S4iEd0EwnEdVvS14Tests264", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedJourneyWhenStoppingAndPassingPointsThenDisplaysCorrectly49ntMponGaH3d2TeFrADTests626", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedJourneyWhenDuplicatedAsrThenDisplaysOnlyOncePcZSkX79OGMg0q3pQn5DTests626", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedJourneyWhenLoadedThenDisplaysOperationalTimesTk4DmRU7XmIasiG1ZnwdTests84", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedJourneyWhenRouteVariantsPresentThenDisplaysExpectedViaTexts243626PSBiHPNaiwU3EWwuI8Wo", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedJourneyWhenFiltersToggledThenDisplaysExpectedFilteredData8gtxUlilUnE990rFs6TQTests243", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedJourneyWhenFilterOptionHasNoElementsThenFilterOptionIsNotDisplayedNcEa7zkv9QkRSKPNEBmVTests243", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedJourneyWhenFilterHasNoDataThenFilterBarIsNotDisplayedZp6yldzlCiYryWGLwxfyTests243", // integration_test/test/reduced_journey_table_test.dart
      @"testRuIndicationsWhenShouldReturnMockDataThenIndicationsAreShownYeJd2tuqjOWvKQcf7RYCTests700", // integration_test/test/ru_indications_test.dart
      @"testRuIndicationsWhenLongTextWithLinkThenShowMoreIsVisibleGiYge5R7YPQAhT07DGhwTests700", // integration_test/test/ru_indications_test.dart
      @"testRuIndicationsWhenLongTextWithMarkdownLinkThenLinkLabelIsRenderedGuPrxy8BQyidLcGugxU0Tests700", // integration_test/test/ru_indications_test.dart
      @"testRuIndicationsWhenLongTextExpandedThenFullContentIsVisibleR66dkeS5LMwlWiwhEvsvTests700", // integration_test/test/ru_indications_test.dart
      @"testServicePointModalWhenBahnhofportalLinkTappedThenOpensExpectedUrlHjOshoAnnns1uiZv1piZTests1485", // integration_test/test/service_point_modal_test.dart
      @"testServicePointModalWhenOpenedThenHidesKilometreColumnZNZVRPa4v1ZbWe1GLNMITests497", // integration_test/test/service_point_modal_test.dart
      @"testServicePointModalWhenInteractedThenOpensAndClosesCorrectlyBULPrI837zbDHbf9ozo1Tests497", // integration_test/test/service_point_modal_test.dart
      @"testServicePointModalWhenSameCellTappedTwiceThenClosesModalBlZZhmecRMoz03Ghc4KoTests1875", // integration_test/test/service_point_modal_test.dart
      @"testServicePointModalWhenRadioChannelTappedTwiceThenClosesModal47UPdaX6hsiYclucw05KTests1875", // integration_test/test/service_point_modal_test.dart
      @"testServicePointModalWhenDifferentServicePointTappedThenSwitchesWithoutClosingYNAh8x76zB856tYRX9MjTests1875", // integration_test/test/service_point_modal_test.dart
      @"testServicePointModalWhenActiveTabReselectedThenDoesNothingQD8ziN2IZxVS5DgO9zJdTests1875", // integration_test/test/service_point_modal_test.dart
      @"testServicePointModalWhenOpenedThenCollapsesHeaderButtonsQ7V14S34B9g0J5ovsSVYTests497", // integration_test/test/service_point_modal_test.dart
      @"testServicePointModalWhenDataAvailableThenShowsOnlyRelevantTabsHCUmXSQ54oN6aACIAwKyTests1040497", // integration_test/test/service_point_modal_test.dart
      @"testServicePointModalWhenTabChangedThenDisplaysCorrectContent7UMIWRPg9Zo3wq1YOhzFTests497", // integration_test/test/service_point_modal_test.dart
      @"testServicePointModalWhenTimeoutThenClosesAutomaticallyL3iVFDwk1kZ8T4ZBo1cWTests497", // integration_test/test/service_point_modal_test.dart
      @"testServicePointModalWhenAdvancementPausedThenClosesAfterTimeoutPzMRSkgLsqo1cXXDrSsfTests497", // integration_test/test/service_point_modal_test.dart
      @"testGraduatedSpeedWhenPresentThenDisplaysInfoDetails4mjc7eeGUBicOSw69JyaTests231", // integration_test/test/service_point_modal_test.dart
      @"testCommunicationTabWhenOpenedThenDisplaysNetworkAndRadioChannels02dNNCKAdwRRIPFdP8rGTests229", // integration_test/test/service_point_modal_test.dart
      @"testCommunicationTabWhenOpenedFromOtherTabThenShowsInformationPNuI8yhc85razhMIsaEzTests229", // integration_test/test/service_point_modal_test.dart
      @"testCommunicationTabWhenDepartureAuthorizationPresentThenDisplaysInModal02darOPX5OqoT03mCvB8Tests226", // integration_test/test/service_point_modal_test.dart
      @"testLocalRegulationTabWhenPresentThenShowsTabG2KZy4GAFAAPIQmDGEFgTests95", // integration_test/test/service_point_modal_test.dart
      @"testLocalRegulationTabWhenTabChangedThenUpdatesDisplayLoEWPFSo4Qcapw2AvhUzTests95", // integration_test/test/service_point_modal_test.dart
      @"testLocalRegulationTabWhenOpenedThenShowsWebviewCCcUxowsksJLPQMqsXTTTests95", // integration_test/test/service_point_modal_test.dart
      @"testServicePointModalWhenModalOpenThenShowsShortSignalNamesD56hz2flGTW6tj4oME9VTests980", // integration_test/test/service_point_modal_test.dart
      @"testServicePointModalWhenNavigatedAndReturnedThenStaysDisplayed1qSvqp8jis2qsg4DKLiOTests497", // integration_test/test/service_point_modal_test.dart
      @"testSettingsWhenOpenedThenShowsHeaderInformationAsZ1tS4kU7Nf5OXr8iPrTests427", // integration_test/test/settings_test.dart
      @"testSettingsWhenCompanySelectedAndUnselectedThenDisplaysSelectionO7WL0FgVcL2yp91SBkO3Tests427", // integration_test/test/settings_test.dart
      @"testSettingsWhenTourSystemSelectedThenDisplaysSelectionVg694p8aplw0hptHokayTests427", // integration_test/test/settings_test.dart
      @"testSettingsWhenDecisiveGradientDisabledThenHidesGradientsDnFjNfPHHPUOOjuVfnrETests583", // integration_test/test/settings_test.dart
      @"testSettingsWhenKmHeaderClickedWithGradientHiddenThenTogglesDisplayLdW7fZGpdN3zYtjjtDUATests583", // integration_test/test/settings_test.dart
      @"testSettingsWhenStationSignalHiddenThenHidesCorrectSignalsWfJtznpIEKWtPVmb9Rw0Tests811", // integration_test/test/settings_test.dart
      @"testSettingsWhenStationSignalHiddenThenChevronPositionsCorrectly3XKYDX4SwTJLxyNqgMoiTests811", // integration_test/test/settings_test.dart
      @"testSettingsWhenStationSignalsToggledThenHidesButKeepsEtcsStopSignsVxFGyvH5oEItemAd3evQTests16281484", // integration_test/test/settings_test.dart
      @"testSettingsWhenEtcsConventionalToggledThenHidesOnlyConventionalStopSignD70x81OKbP7Mf1fPtJeJTests16281484", // integration_test/test/settings_test.dart
      @"testSettingsWhenEtcsExtendedToggledThenHidesOnlyExtendedStopSignsWyFGcqFBAgRTeltqj00QTests16281484", // integration_test/test/settings_test.dart
      @"testSettingsWhenBothEtcsToggledOffThenHidesAllEtcsStopSignsX7guyj0RrgJ3kyCghZapTests16281484", // integration_test/test/settings_test.dart
      @"testShortTermChangesWhenPresentThenDisplaysAllCorrectlyInJourneyTableRpkZRlCOuFvVOdilaJ3HTests99", // integration_test/test/short_term_changes_test.dart
      @"testShortTermChangesWhenPresentThenDisplaysAllCorrectlyInFlapKSHBUNCrkaLVbI9O4davTests99", // integration_test/test/short_term_changes_test.dart
      @"testSuspiciousSegmentWhenLoadedThenShowsRowsAndNotificationAndDismissesEHJMbX24ewGWgg10BEZqTests409", // integration_test/test/suspicious_segment_test.dart
      @"testSuspiciousSegmentWhenAllPassedThenDisappearsAndReappearsOnUpdateOBl4K6VmunFHbxfUZby8Tests409", // integration_test/test/suspicious_segment_test.dart
      @"testSuspiciousSegmentWhenJourneyUpdatedThenShowsNotificationCqASKmxsyq2yekUchh6yTests409", // integration_test/test/suspicious_segment_test.dart
      @"testTourSystemWhenNotConfiguredThenHidesButtonsJpXgUIrH7wxQNvb04ZMJTests96", // integration_test/test/tour_system_link_test.dart
      @"testTourSystemWhenConfiguredThenShowsButtonsDNnl6Kr0CR51GHFbwop5Tests96", // integration_test/test/tour_system_link_test.dart
      @"testTourSystemWhenPositionChangesThenUpdatesButtonVisibilityLSHbN4Urksjx7NapW9GOTests96", // integration_test/test/tour_system_link_test.dart
      @"testTrainSearchWhenPageLoadedThenShowsDefaultValuesYJsLvmX6PrhDbt3GNctgTests92", // integration_test/test/train_search_test.dart
      @"testTrainSearchWhenCompanySelectionOpenedThenShowsOptions4V8lVLIAXkStk9lkHcFvTests92", // integration_test/test/train_search_test.dart
      @"testTrainSearchWhenRuFilterEnteredThenFiltersResultsK9LxJibBfWA0sakjBxjUTests596", // integration_test/test/train_search_test.dart
      @"testTrainSearchWhenNoTrainNumberEnteredThenDisablesButton3JEyvxxjnxVGfeAOufjKTests92", // integration_test/test/train_search_test.dart
      @"testTrainSearchWhenYesterdaySelectedThenShowsWarningRh6SvdbhmUIBNyDfPXfOTests92", // integration_test/test/train_search_test.dart
      @"testTrainSearchWhenDayBeforeYesterdayThenCannotSelectT4mNyzwoakPFwz6CYPkaTests92", // integration_test/test/train_search_test.dart
      @"testTrainSearchWhenJpUnavailableThenShowsErrorIPmnmRoSSpBBs6aHadTkTests92", // integration_test/test/train_search_test.dart
      @"testTrainSearchWhenErrorFromSferaThenDisplaysErrorCode9UIII436R7pMUXwLx6zRTests652", // integration_test/test/train_search_test.dart
      @"testTrainSearchWhenMultipleCompanyMatchesThenShowsSelectionEdyQLmRIb617kcxR5XXNTests702703", // integration_test/test/train_search_test.dart
      @"testTrainSearchWhenLastCompanyCodeRememberedThenAutoSelectsG6t83P9j45q6KfT4Y70fTests702", // integration_test/test/train_search_test.dart
      @"testTrainSearchWhenNoCompanyMatchThenShowsNoResultMessageWQ4rTB8lZNGl5HW7Dbq0Tests702", // integration_test/test/train_search_test.dart
      @"testWarnappWhenSignalIsRedThenTriggersWarningFyC1jKH9cdcBV12PSb7qTests98", // integration_test/test/warnapp_test.dart
      @"testWarnappWhenUiRebuiltThenNotificationNotReappearingUoTbX3SWk0ErQ5UKnyPQTests98", // integration_test/test/warnapp_test.dart
      @"testWarnappWhenManeuverButtonTappedThenActivatesManeuverModeFzvOU1FQOyjnN2eS2nO0Tests98", // integration_test/test/warnapp_test.dart
      @"testWarnappWhenInManeuverModeThenDoesNotTriggerL1acZ9QnjvNYwfLsKH9YTests98", // integration_test/test/warnapp_test.dart
      @"testWarnappWhenSignalIsGreenThenDoesNotTrigger8eVsobX4adhhZeX7htwvTests98", // integration_test/test/warnapp_test.dart
  ];
}

static NSMutableDictionary<NSString *, NSString *> *RunnerFailures;
static NSMutableSet<NSString *> *RunnerSuccesses;
static BOOL RunnerDidRun = NO;

@interface RunnerTests : XCTestCase
@end

@implementation RunnerTests

// Runs the Flutter suite once, lazily, from inside the first test that executes.
+ (void)ensureIntegrationTestsExecuted {
  @synchronized(self) {
    if (RunnerDidRun) {
      return;
    }
    RunnerDidRun = YES;
    RunnerFailures = [NSMutableDictionary new];
    RunnerSuccesses = [NSMutableSet new];
    FLTIntegrationTestRunner *runner = [[FLTIntegrationTestRunner alloc] init];
    [runner testIntegrationTestWithResults:^(SEL testSelector, BOOL success, NSString *failureMessage) {
      NSString *name = NSStringFromSelector(testSelector);
      if (success) {
        [RunnerSuccesses addObject:[name lowercaseString]];
      } else {
        RunnerFailures[name] = failureMessage ?: @"(no message)";
      }
    }];
  }
}

// Adds one XCTest method per Flutter test at runtime. Nothing runs here, so the
// Xcode construction-phase watchdog is not involved, and BrowserStack sees one method.
+ (NSArray<NSInvocation *> *)testInvocations {
  NSMutableArray<NSInvocation *> *invocations = [NSMutableArray array];
  for (NSString *name in RunnerDartTestNames()) {
    SEL selector = NSSelectorFromString(name);
    IMP implementation = imp_implementationWithBlock(^(XCTestCase *testCase) {
      [RunnerTests ensureIntegrationTestsExecuted];
      if (![RunnerSuccesses containsObject:[name lowercaseString]]) {
        NSString *message = RunnerFailures[name] ?: @"not recorded";
        XCTIssue *issue = [[XCTIssue alloc] initWithType:XCTIssueTypeAssertionFailure
                                      compactDescription:[NSString stringWithFormat:@"%@: %@", name, message]];
        [testCase recordIssue:issue];
      }
    });
    class_addMethod(self, selector, implementation, "v@:");
    NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    [invocations addObject:invocation];
  }
  return invocations;
}

@end
