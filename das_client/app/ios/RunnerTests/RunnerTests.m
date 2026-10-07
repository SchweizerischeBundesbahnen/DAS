@import XCTest;
@import integration_test;
@import ObjectiveC.runtime;

// One entry per Flutter test. Generate this list the same way the current
// generator produces the test methods.
static NSArray<NSString *> *RunnerDartTestNames(void) {
  return @[
      //GENERATED CODE
      @"testAsrmodalWhenmodalopenedThenhidestimecolumnP7YdfbghpvgmoyasfnjfTests1219", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAsrmodalWhenmissingoptionalfieldsThenshowsdashesDjrbxirx37Dq6Cvl1NlxTests567", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAsrmodalWhenalldetailspresentThenshowsalldetails0Eqj41Iwn8Ueyne4Nzh2Tests567", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAsrmodalWhensamerowtappedtwiceThenclosesmodalPjosypi4Xqrzfe8UsgtdTests1875", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAsrmodalWhenradiochanneltappedwhileopenThenswitcheswithoutclosingFycl15Anxotsmygvuzl3Tests1875", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAsrmodalWhennoninteractiveareatappedThenclosesmodalJajhl07W13Dg4G0WsctjTests1875", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAsrmodalWhencomplexasrwithmultipleentriesThenshowsallentries4Dhyrq0I6Dm7WccmpmdrTests227", // integration_test/test/additional_speed_restriction_modal_test.dart
      @"testAppexpirationWhenexpiressoonThenshowsdismissibledialogonceWdtkidfsmgo3Zr9DwxhhTests245", // integration_test/test/app_expiration_test.dart
      @"testAppexpirationWhenexpiredThenshowsnondismissibledialogRppcazq2Uo5W3Xr0IzlgTests245", // integration_test/test/app_expiration_test.dart
      @"testApplinkWhenlinkwithsingletrainOpensjourneyN2Dspgyq3Ku5M4Zwxh7QTests97", // integration_test/test/app_link_test.dart
      @"testApplinkWhenlinkwithmultipletrainsOpensfirstjourneyandrestinnavigationFvylq39Apcu9HxydxoreTests97", // integration_test/test/app_link_test.dart
      @"testApplinkWhenlinkwithvalidandunknowntrainOpensfirstjourneyandshowserrorpageforsecondPekbdz3Nheevcicqd6WyTests97", // integration_test/test/app_link_test.dart
      @"testApplinkWhenlinkwhileunauthenticatedOpensjourneyafterloginflowAzdiagi51Vkrpz2ShznrTests97", // integration_test/test/app_link_test.dart
      @"testApplinkWhenlinkwithunknowntrainShowserrorpage15G1Jt1Szm8J2Gsw3MbsTests97", // integration_test/test/app_link_test.dart
      @"testApplinkWhenlinkwithtaftapstartandendShowstraindriverturnoverrowsTliaikurerftrsyxwv1STests296", // integration_test/test/app_link_test.dart
      @"testApplinkWhenlinkwithreturnurlShouldusereturnurloverdefaulttoursystemurlB6Vkx9Lfhgrkizsz1Us6Tests9796", // integration_test/test/app_link_test.dart
      @"testApplinkWhenalreadyonjourneypagereceivingdeeplinkOpensnewjourneyRwoqbfy4K3Xnudz0SdxoTests1852", // integration_test/test/app_link_test.dart
      @"testApplinkWhenlinkwithsingletrainShowscompanymatchselectionWrcsxpxpyvtjofkqofynTests702", // integration_test/test/app_link_test.dart
      @"testApplinkWhenalreadyonjourneypagereceivingdeeplinkOpensselectionwithcompanymatchMsfnfsboibb94SxzptbdTests702", // integration_test/test/app_link_test.dart
      @"testApplinkWhenalreadyonjourneypagereceivingdeeplinkOpensnewjourneywithmatchingru3Rmlqu5Rkmlbwnkw3HatTests702", // integration_test/test/app_link_test.dart
      @"testAutomaticadvancementWhenjourneyloadedThenscrollsautomaticallyZgzabcsbv7Ppjgvndu2MTests94", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticadvancementWhenidletimereachedThenscrollsbacktoposition78V0Rplxi8A6Lgzwhf3RTests94", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticadvancementWhentableistappedThenidletimeisnotresetO2Jzoxivpjxpp5Kp71BtTests1923", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticadvancementWhentableisscrolledThenidletimeisresetCwg37Cldza4TygxweeusTests192394", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticadvancementWhenreenabledThenscrollstocurrentposition4Ia2Ip74Kn6Fpymenx80Tests94", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticadvancementWhendisabledThendoesnotscroll4Jebtnrj2Fhdv4Ab1Fx9Tests94", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticadvancementWhenjourneyloadedThenisenabledbydefaultQolt57Vft3Usf96YbyjaTests94", // integration_test/test/automatic_advancement_test.dart
      @"testAutomaticadvancementWhendisabledThenshowsstickyfooter2Unryr5Awqhqmmyn9QaeTests94", // integration_test/test/automatic_advancement_test.dart
      @"testTimedadvancementWhenjourneyloadedThenadvancescorrectly6Vsc8W1Yfguw4Cktbx7QTests1419", // integration_test/test/automatic_advancement_test.dart
      @"testTimedadvancementWhenjourneyloadedThenadvancesbyoperationalandplannedtimesKp3Wqzt9Rlxyhnv2QmdeTests939", // integration_test/test/automatic_advancement_test.dart
      @"testTimedadvancementWhensignaledpositionbehindandpunctualityhiddenThensignalwinsXw7Rtlm2Qpkvyc9Hbnd3Tests2491", // integration_test/test/automatic_advancement_test.dart
      @"testBrakeslipWhenpositionupdatewhilebrakeslippageopenThendoesnotupdatetonewpositionLqq9Jbqezxkwyjm3VwyfTests1605", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipWhennodataavailableThendoesnotshowbutton4Z9DtxcnpqahgoefcxqoTests692568", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipWhenformationdataloadedThenshowsinformationandnavigationLtujgubevybkxbp0MwcsTests692", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipWhenbrakedetailsfeatureenabledThenshowsbrakedetailsUsaiof7Ht1Rlvsopkhb6Tests2641", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipWhenbrakedetailsfeaturedisabledThenhidesbrakedetailsOtnw80Xp0SracqujlfcjTests2641", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipWhenspecialindicatorsarepresentThenshowsbannersYgf4Hhe8Cl7C98Nac5XjTests692", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipWhendifferentbrakeseriesinformationThenshowsnotificationNfiita4Nbxj20Vkgcgh0Tests692", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipmodalWhenopenedThendisplayscorrectinformationLxpggimjzbu9W3AonnewTests692568", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipmodalWhenidletimeoutelapsesThenneverclosesautomatically1G0A50LfmqosffqkwrkjTests1867", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipmodalWhenbuttontappedwhileopenThenclosesmodal7Vngjkboifqc2QmseuwsTests1875", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipmodalWhennoninteractiveareatappedThenclosesmodal4U1Bk9Vv17S4H9RpuqxmTests1875", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipmodalWhenfullscreenbuttontappedThenopensfullscreenSltlsninc1Xwv6Sv6GvkTests692", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipWhenformationupdatedThenshowsnotificationHt9Hpozmhcatzuyqb4RfTests695", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipWhenformationrunchangedThenupdatesrunchangedisplayIg1Dyvhq8Huk2UhyomojTests694", // integration_test/test/brake_load_slip_test.dart
      @"testBrakeslipWhentransportdocumentsareconfiguredThenbuttonvisibilityandlaunchbehaviormatchformationdataK2Dx0Vd8R1Sz9Fqm7UjmTests1620", // integration_test/test/brake_load_slip_test.dart
      @"testChronographWhennoupdatesThenhidespunctualitydisplayRhunle41Envoe7Vzk3UpTests300", // integration_test/test/chronograph_test.dart
      @"testChronographWhennoupdatesThenpunctualitybecomesstale1W4Nytamrijrry9Nzjj0Tests300", // integration_test/test/chronograph_test.dart
      @"testChronographWhenpunctualityupdatereceivedThendisplayscorrectlyCa2H5Q5Rfvvivzjocl9ITests300", // integration_test/test/chronograph_test.dart
      @"testChronographWhennocalculatedspeedandnoplannedtimesThenhidespunctuality8Bo2Dgfbglmqvht7MrlbTests19692257", // integration_test/test/chronograph_test.dart
      @"testChronographWhennosferadelayavailableThenshowsplannedtimedeviationIxktmp5Ojttzd7Eo7Vf5Tests1851", // integration_test/test/chronograph_test.dart
      @"testChronographWhenplannedtimedeviationfeaturedisabledThennevershowsdeviationIk64Kpz9J4Qn3KlsockbTests1851", // integration_test/test/chronograph_test.dart
      @"testChronographWhenjourneyloadedThenshowscorrectcurrenttimeXvdcwlyyq41Hhar9P2HmTests79", // integration_test/test/chronograph_test.dart
      @"testClosejourneyWhentrainnotinmotionThencloseswithoutconfirmationOzopj2Dv77Yjmnggfb3LTests2219", // integration_test/test/close_journey_test.dart
      @"testClosejourneyWhentraininmotionanddismissedThenstaysonjourneyL0Sday1Hffdw8Kz5W4UqTests2219", // integration_test/test/close_journey_test.dart
      @"testClosejourneyWhentraininmotionandconfirmedThenclosesjourneyMqdaitcqlvtmatyuwwjjTests2219", // integration_test/test/close_journey_test.dart
      @"testJourneysearchoverlayWhenopenedThenshowsnoconfirmationImamqzatvhzq6PwsfwpxTests2219", // integration_test/test/close_journey_test.dart
      @"testJourneysearchoverlayWhennewtrainloadedanddismissedThenstaysonjourneyLk3Zlofv6Lng08Nyvwb2Tests2219", // integration_test/test/close_journey_test.dart
      @"testJourneysearchoverlayWhendifferenttrainloadedandconfirmedThenloadsotherjourney8B0Dxfqyhlwo6Ocv6TqwTests2219", // integration_test/test/close_journey_test.dart
      @"testDepartureprocessWhenfeatureenabledThenchecklistbuttondisplayedcorrectlyNw7Qkkijklymlt0Yngj6Tests627", // integration_test/test/departure_process_test.dart
      @"testDepartureprocessWhennocustomerorienteddepartureThenchecklistbuttonopensdeparturedialogLwlj8Frlqy7Pbq76LgkuTests627", // integration_test/test/departure_process_test.dart
      @"testDepartureprocessWhenfeatureenabledThenshowschronographwarningNqr5G6Ro4Aw4Aezlyzl4Tests627", // integration_test/test/departure_process_test.dart
      @"testExternallinksWhennocompanyselectedThenshowsemptystateYwizuavbvmwzqn5OoqieTests147", // integration_test/test/external_links_test.dart
      @"testExternallinksWhencompanyselectedinsettingspageThenshowscorrectlinksVnfgpqg3Ma8VupxenmkyTests147", // integration_test/test/external_links_test.dart
      @"testExternallinksWhencompanyselectionchangesThenupdateslinksMzf1Gipytu39GeqhczcaTests147", // integration_test/test/external_links_test.dart
      @"testCustomerorienteddepartureWhenstatuschangesThendisplaysnotificationscorrectlyDiw8Ooyfmkindzpgcp4STests148", // integration_test/test/journey_customer_oriented_departure_test.dart
      @"testCustomerorienteddepartureWhenjourneychangesThensubscriptionupdates7Cmv7S3VxpmskqjvucxdTests148", // integration_test/test/journey_customer_oriented_departure_test.dart
      @"testJourneyheaderWhenconnectivitychangesThenshowscorrectstateInnxrgqxweq3Dkjj5XkoTests119", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhenjourneyloadedThenturnsonalwaysondisplayWxr40HihesioewydjtedTests591", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhenjourneyclosedThenturnsoffalwaysondisplay85Sj2C4Mlmjhgoj8QzcxTests591", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhentrainactiveThenhidesappbarY8Vn9Cr9Fywhirxbzq68Tests79670", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhenthemeswitchtappedThenswitchesthemeZhltx4Wiqlsmqxd537PsTests102", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhenextendedmenuopenedThenshowsclosebutton3Nd51Aamnm7Ziq6JqujsTests497", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhenmaneuvermodetoggledThenshowsnotificationCnrguvzwd6Cz1WjtrpnmTests242", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhenmaneuvernotificationswitchtappedThenhidesnotificationXqixbnfdnl2YeeegdmmtTests242", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhenwaraappinstalledandmaneuvermodeThenshowswaraapplinkMfgc6Wm2Zhgavzoru19ZTests242", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhenwarnappdisabledThenhidesmaneuvermodeTwnozeohbpzvpfl5L5TtTests242445", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhenwaraappinstalledThenshowsopenmenuitemBc5Toxjbc31R6U4Oe66LTests242", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhenbatteryabove15PercentThenhidesicon5Ehxse0Aany05Pmacf9GTests123", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhenbatterybelow15PercentThenshowsiconandmodalEm5Ecudyqo96Tv29Cg28Tests123590", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhencommunicationnetworkchangesThendisplayscorrectlyC3Ikkuijmloz0Xz3GsptTests125", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhenradiocontactschangeThendisplayscorrectlyTr4Sky5Hk17Bxb622PstTests125", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhendoubletappedThensetsbrightnesstozeroO8Gnedoxv3QsxnynimpkTests101", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhendraggedrightThenincreasesbrightnessDsetqydlocusgsqfmnmtTests101", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhendraggedleftThendecreasesbrightnessVenb2YzwbokurpbzfdswTests101", // integration_test/test/journey_header_test.dart
      @"testJourneyheaderWhendepartureauthorizationpresentThendisplayscorrectly1Kg0Kdpujd6Ndmn4Q7C6Tests226", // integration_test/test/journey_header_test.dart
      @"testNotificationWhendepartureprocessdialogopenedThendisplayscorrectlyT2Ga4Z72Zhw01N8Dya7MTests624627", // integration_test/test/journey_notification_test.dart
      @"testNotificationWhendisturbanceoccursThenshowsandhidesnotificationM1Oe34O4N52Uyyirvmu2Tests244", // integration_test/test/journey_notification_test.dart
      @"testNotificationWhendeparturedispatchreceivedThendisplayscorrectlyXgzcksb39KkesylhsvywTests124", // integration_test/test/journey_notification_test.dart
      @"testNotificationWhenmultiplenotificationsThenprioritizescorrectlyJ6Off00Oszo3Qqy0XdqmTests1402", // integration_test/test/journey_notification_test.dart
      @"testNotificationWhenreauthenticationrequiredThenshowsnotificationJvuwuj6R5Melk0DpaauwTests1320", // integration_test/test/journey_notification_test.dart
      @"testReplacementseriesWhensuggestedThenselectsandreturnstooriginalMm0Ytfua6Pymsusjg4TrTests507", // integration_test/test/journey_replacement_series_test.dart
      @"testReplacementseriesWhennoreplacementavailableThendoesnotsuggestUlgxunaeoxdqnsbksvyiTests507", // integration_test/test/journey_replacement_series_test.dart
      @"testReplacementseriesWhenendofsegmentreachedThenmessagedisappearsLizlpyffxgbtt95ZmbirTests507", // integration_test/test/journey_replacement_series_test.dart
      @"testReplacementseriesWhennoreplacementforbrakeseriesThenshowsnotificationNvohvz4Dmlz4SanartplTests938", // integration_test/test/journey_replacement_series_test.dart
      @"testJourneysearchoverlayWhenopenedanddismissedThentogglescorrectlyHjtzmqmajvvbofkjfxjiTests456", // integration_test/test/journey_search_overlay_test.dart
      @"testJourneysearchoverlayWhenopenedThenshowsdefaultsandvalidation7Pjrxknm1Dj2SoexzetoTests456", // integration_test/test/journey_search_overlay_test.dart
      @"testJourneysearchoverlayWhentrainloadedThenopensjourneywithoutnavigationbuttonsPffjikgb8Rju5Bakp7S1Tests456", // integration_test/test/journey_search_overlay_test.dart
      @"testJourneysearchoverlayWhenmultiplecompanymatchesThenredirectstoselectionscreen78G6Wgafp4Dv86Tsgl14Tests702", // integration_test/test/journey_search_overlay_test.dart
      @"testAdditionalspeedrestrictionWhenrowdisplayedThenshowscorrectlyH60Hiyvcm6InpqtwssdiTests87", // integration_test/test/journey_table_additional_speed_restriction_test.dart
      @"testAdditionalspeedrestrictionWhennonasrrowsbetweenThencolorscorrectlyYa4Ssmxttnzic4SckmrcTests87", // integration_test/test/journey_table_additional_speed_restriction_test.dart
      @"testAdditionalspeedrestrictionWhencomplexasrThendisplayscorrectlyPe2Toyhui8Ow7Pkpelj7Tests227", // integration_test/test/journey_table_additional_speed_restriction_test.dart
      @"testAdditionalspeedrestrictionWhenonetcslevel2SectionThendisplayscorrectlyX08Sts2Qub7Tn1U8HhnyTests120", // integration_test/test/journey_table_additional_speed_restriction_test.dart
      @"testAdditionalspeedrestrictionWhensequentialasrThendisplayscorrectlyJsco6TecyuhpkczmzrxeTests566", // integration_test/test/journey_table_additional_speed_restriction_test.dart
      @"testAdvisedspeedWhennotificationreceivedThendisplayscorrectlyDifsm3D1Efvskjn1IjjjTests22812851306", // integration_test/test/journey_table_advised_speeds_test.dart
      @"testAdvisedspeedWhenjourneyloadedThendisplayscorrectly85Diebkyiatnr4Kwts5CTests22812851306", // integration_test/test/journey_table_advised_speeds_test.dart
      @"testBaliselevelcrossingWhenmultiplelevelcrossingsThendisplayscorrectlyB4VseswdglqamsxgpzpeTests2241416", // integration_test/test/journey_table_balise_level_crossing_test.dart
      @"testBaliselevelcrossingWhengrouptappedThenexpandsandcollapsesAwz0Lekhyrcse2VmtxprTests2241416454", // integration_test/test/journey_table_balise_level_crossing_test.dart
      @"testBaliselevelcrossingWheninetcslevel2SectionThendisplayscorrectlyX6KedrpffrkszlgfygtmTests14291416224", // integration_test/test/journey_table_balise_level_crossing_test.dart
      @"testBrakeseriesWhendefaultmissingThenshowsquestionmarksE3Ydk2Vupdfknzxenqh1Tests89", // integration_test/test/journey_table_brake_series_test.dart
      @"testBrakeseriesWhendefaultfromtraincharacteristicsThenshowsr1158Cowwi2Zvgkhncg31PgpTests89", // integration_test/test/journey_table_brake_series_test.dart
      @"testBrakeseriesWhenopenedThenshowsalloptions8Ipnevrzhcbzoth6Ao2KTests89", // integration_test/test/journey_table_brake_series_test.dart
      @"testBrakeseriesWhennobrakeseriesdefinedThenshowsmessageNzj1S9Oceiobi3FtabvrTests89", // integration_test/test/journey_table_brake_series_test.dart
      @"testCalculatedspeedWhenjourneyloadedThendisplayscorrectlyMfggjrqkcllfspfi6MaoTests88367", // integration_test/test/journey_table_calculated_speed_test.dart
      @"testCalculatedspeedWhendisplayedinstickyheaderThenshowscorrectlyYx1Ukcecluwqdnfyq6ZrTests88367", // integration_test/test/journey_table_calculated_speed_test.dart
      @"testCalculatedspeedWhennovprospeedatpositionThenhidespunctualityDlsoheuaer1XbsyumjntTests88122", // integration_test/test/journey_table_calculated_speed_test.dart
      @"testCalculatedspeedWhenreducedtolinespeedThendisplaysindifferentcolorMk8Pekt17Hljlrlqxmz9Tests88367", // integration_test/test/journey_table_calculated_speed_test.dart
      @"testCollapsiblerowsWhenoperationalindicationdisplayedThencollapsesIacfo6Crqrax4PorwjubTests126", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsiblerowsWhenradnfootnotedisplayedThencollapsesClmysuxh6Doypt2Xgln8Tests625", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsiblerowsWhenlongtextpresentThenshowsmorebuttonLegwtoyfxwlaumjiwddmTests126", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsiblerowsWhencombinedindicationsThenreplacesnewlineswithdelimiterWn0E9Hexjfz8Lk3XegvaTests126625", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsiblerowsWhensameservicepointThencombinesindicationandfootnotePkzjtpxxkinflc3Iis74Tests126625", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsiblerowsWhenoperationalindicationpassedThencollapsesH9JlgrvgfpycsgewwmyxTests126", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsiblerowsWhenradnfootnotepassedThencollapsesSlbiwzyeccfkwy77CqrzTests625", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsiblerowsWhenradnfootnotedisplayedThentitlecontainstype8Xcuhwpmji1IjgizgfsdTests625", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testSimfootnoteWhennonsimtrainThensimfootnoteiscollapsedGnypge8Jjpnkhq6Cbsm1Tests1126", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testSimfootnoteWhensimtrainThensimfootnoteisexpandedandnotcollapsedwhenpassedWgzkdpjtffukkjknw92KTests1126", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsiblerowsWhenmovingbackwardsThenresetrowstodefaultsate60Qulbjufk7Kipulz6LbTests1617", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsiblerowsWhenlinefootnoterepeatedThenrepetitionsarecollapsedbydefault156Zlpeedk5Czan0BpcmTests2219", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testCollapsiblerowsWhenmovingbackwardsThenlinefootnotesareresettotheirdefaultN1P736Tbykrbbz4Iom2XTests2219", // integration_test/test/journey_table_collapsible_rows_test.dart
      @"testStationpropertyWhenstationsignspresentThendisplayscorrectly33P6HqftzihpswxiqymfTests127", // integration_test/test/journey_table_station_property_test.dart
      @"testStationpropertyWhenpropertiespresentThendisplayscorrectly2048M4Ei2Xwf3Xp9FnzrTests127", // integration_test/test/journey_table_station_property_test.dart
      @"testStationpropertyWhentrainserieschangesThenupdatesdisplay6Yg8Vyvmt02Jomus9RdcTests127", // integration_test/test/journey_table_station_property_test.dart
      @"testJourneytableWhencurvespresentThendisplaysendofcurvescorrectlyGfsq5X3EgvhqdizfmdamTests478", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhensummarizedcurveThendisplaysasoneFsnnju7Cwww3Zx7ZxrfqTests584", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenkilometerandnetworkchangesThendisplayscorrectly4R5G55Qzylcbrpp8BwycTests1251237356", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhengradientpresentThendisplaysupanddownhillWivyo0Q3Nnowuwnkvm28Tests225", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenbrakeseriesa50ChosenThenfindstwocurves6DftwlixiswnwpyqibjjTests478584", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenbrakeseriesr115ChosenThenfindsthreecurvesGa09Ybxy1Saxs4SdpfkqTests478584", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenwhistleandtramareaThendisplayscorrectlyUsmlmc9Mbo7Ngo9Crec8Tests224", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenchevroningroupeditemsThenpositionscorrectlyJoe81L2AczcxfgnhasnyTests94", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhendefaultbrakeseriesThenshowscorrectspeedvalues8X1Ka8Bgi8Yzoh4UjfzaTests89", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenmissingbrakeseriesThenshowscorrectspeedvaluesLlhbviwehyzfnedkofeeTests89", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenconnectiontrackandzahnstangepresentThendisplayscorrectlyUk1Rmjxg0Jcgsi5ArethTests136", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenloadedThenshowsallcolumnswithheaders2Xkqzqkinzvqyxlvy6H4Tests79", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenroutepresentThendisplayscorrectlyRyz21Ezspmxaa5NgydjjTests801557", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenprotectionsectionspresentThendisplayscorrectlyHw5Shuks9Djre4Ik706ZTests223", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenbothkilometrespresentThendisplaysbothGxhdmhah4BtjsxlsqhccTests1863", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenbracketstationsThendisplayscorrectlyR7Bvetxlois8Nat7DgnvTests81", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenhaltonrequestThendisplayscorrectlySvxw9Sgr7Xui7ZbberszTests81", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenhaltpresentThendisplaysitalicPsvc3Eahhti7Mnl15VlnTests81", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenservicepointhastrackgroupThendisplayscorrectlywithdetailmodalGobfvft2Aaypwmxp9CenTests1072", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhencurvespresentThendisplayscurvescorrectlyPnclwjdbimf8IumwaxueTests82", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhensignalspresentThendisplayscorrectly17Wdiw5Hyko2IvvtiobpTests82", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenstationspeedsThendisplayscorrectlyFxmx5Vrkhafegsmwh1G5Tests82", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenlinespeedThenalwaysdisplaysinstickyheaderJd3Nqcaive8Ivy8CnawmTests932", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenetcslevel2SectionThenhideslinespeed3Qrwumgq0Aqm4HaxpnjlTests120", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenadditionalservicepointsThendisplayscorrectlyIfrok0Ce5Yyxlnxw2CzbTests258", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenshuntingmovementThendisplaysmarkerscorrectly1Hj3Sn82MojhdbszhwudTests264", // integration_test/test/journey_table_test.dart
      @"testJourneytableWhenmultiplecolorsThendisplayscorrectpriorityBedmots6Ncw5Xayvseo6Tests1125", // integration_test/test/journey_table_test.dart
      @"testTimecellWhenfixedpointrelevanceDisplaycorrecticons3Lgb8Le756Lixsoviyg8Tests1201", // integration_test/test/journey_table_time_test.dart
      @"testTimecellWhenfarfuturejourneyThenshowsplannedtimesonly8Vwuvllyxynacmpov6JxTests84", // integration_test/test/journey_table_time_test.dart
      @"testTimecellWhennearfuturejourneyThenshowsoperationalandplannedtimesNx7Awinxvpgmh5BqoxmgTests84", // integration_test/test/journey_table_time_test.dart
      @"testTimecellWhenmanuallysettoplannedThenautoswitchesbacktooperationalZjevf25WtmgjfcmnagnfTests84", // integration_test/test/journey_table_time_test.dart
      @"testTimecellWhendeparturetimereachedThenunderlinestime9Eqakyvdxrj4E7Fzh6AeTests259", // integration_test/test/journey_table_time_test.dart
      @"testTrackequipmentWhencabsignalingThendisplayscorrectlyDnu1Agjjoxuhg1Ka8ZhsTests82", // integration_test/test/journey_table_track_equipment_test.dart
      @"testTrackequipmentWhenloadedThendisplayscorrectlyYublapq3Bgd4BwgvhgojTests82", // integration_test/test/journey_table_track_equipment_test.dart
      @"testTrackequipmentWhensingletracknoblockThendisplayscorrectlyUvrmeube4Z8Gqxu9Zw3BTests230", // integration_test/test/journey_table_track_equipment_test.dart
      @"testJourneyupdatesWhenchangesreceivedThendisplayscorrectlyRcw5QkoqduwtfxveeihrTests241", // integration_test/test/journey_table_updates_test.dart
      @"testJourneyupdatesWhenmodificationsacknowledgedThenhandlesacknowledgeundoandvisibilityQcfafzgvqun2Ea6Aoh8ZTests2218", // integration_test/test/journey_table_updates_test.dart
      @"testJourneyupdatesWhentraincharacteristicsupdatedThenignoresupdateLd7G7Ossekkpbbgjj5AmTests1416", // integration_test/test/journey_table_updates_test.dart
      @"testJourneyvalidationWhenactivatedThenallowsmultiplebrakeseriesselectionanddisplaysX0Mynzy28I2Ijmp07SsbTests2734", // integration_test/test/journey_validation_test.dart
      @"testLoginWhenlogoutdialogisdismissedThenisstillloggedinQrcd5Jy91Tve7Kucfsq7Tests1870", // integration_test/test/login_test.dart
      @"testLoginWhenstarteddefaultforintegrationtestThenisconnectedtomockbrokerO1Ttzfxvce93K82Zfcob", // integration_test/test/login_test.dart
      @"testLoginWhenlogoutThendefaultselectionistmsvadonloginpageMgpv1Rit2X8BfrjxjhsdTests2399", // integration_test/test/login_test.dart
      @"testLoginWhenlogoutthenloginThenwillconnecttotmsvadVezt1C1Nxqkljokbjk7QTests2399", // integration_test/test/login_test.dart
      @"testLoginWhenlogoutthenloginwithsferamocktoggledThenwillconnecttosferamockUcmthmlv4Xgl5Dw8BdeoTests2399", // integration_test/test/login_test.dart
      @"testManualadvancementWhenservicepointdraggedThenjourneypositionmovedIu0Xywtq0Mgpanerdou9Tests741", // integration_test/test/manual_advancement_test.dart
      @"testManualadvancementWhenmanualpositionsetThenmanualmodeactivateduntiljourneypositionsignaledVf1Buwaj8Ok5Qj9NsrvzTests741", // integration_test/test/manual_advancement_test.dart
      @"testManualadvancementWhenmanualpositionsetThenstarttimedadvancementQidaqqpf9ZctfyvurotnTests1314", // integration_test/test/manual_advancement_test.dart
      @"testManualadvancementWhenmanualpositionsetThenrestartspositiontimersTvzbkb7A7Zmsilorpp0OTests1314", // integration_test/test/manual_advancement_test.dart
      @"testManualadvancementWhenmanualpositionsetThenshowschevronanimationcolorRdlrfyar0Jbcplagyvb1Tests1617", // integration_test/test/manual_advancement_test.dart
      @"testNavigationWhendraweropenedThenshowsallnavigationitems4Zq12YxohybvffmmbrmuTests80", // integration_test/test/navigation_test.dart
      @"testNavigationWhenlinksselectedThenshowslinkspage6Ud9Zviyraalfwadmi7BTests80", // integration_test/test/navigation_test.dart
      @"testNavigationWhensettingsselectedThenshowssettingspageNse6Erby0UokifbulzbaTests80", // integration_test/test/navigation_test.dart
      @"testNavigationWhensupportselectedThenshowssupportpageUwgtlis6Brdbdk4ShrwjTests80", // integration_test/test/navigation_test.dart
      @"testNavigationWhenjourneyselectionpageselectedThenshowsselectionpageF5Ahhw7Wfexfvwdrzzh6Tests80", // integration_test/test/navigation_test.dart
      @"testNavigationWhennavigatingbacktojourneyThenjourneystaysloadedTvsaoe6Gbj5Bwoqpd2V1Tests801557", // integration_test/test/navigation_test.dart
      @"testNavigationWhennavigatingbackThenjourneysettingsnotresetRijoj3T18MvgvznmrmtqTests80583811", // integration_test/test/navigation_test.dart
      @"testPersonalnotesWhencreatethenupdatenoteThenupdatesmodal1Vehh7UmxywgkqoozoicTests1009", // integration_test/test/personal_notes_test.dart
      @"testPersonalnotesWhenexistingsingleuseandgeneralanddeleteafterwardsThenshowssingleusethengeneralthennothing4Uzzwz3Sww0Iyo7OidajTests1009", // integration_test/test/personal_notes_test.dart
      @"testPersonalnotesWhencreatenoteasfootnotethendeleteThenupdatesjourneytable3Zcteqwjafzrlmjae4UyTests1009", // integration_test/test/personal_notes_test.dart
      @"testPersonalnotesWhencreatesingleusenoteThenonlyshowsincurrentjourneyUbhchmmwcvtq6QejzjrjTests1009", // integration_test/test/personal_notes_test.dart
      @"testPreloadWhenstatuschangesThendisplayscorrectlyVzryogxmwq20YjramwsnTests90", // integration_test/test/preload_test.dart
      @"testPreloadWhenusingpreloaddataThenreconnectssuccessfullyNw5Bzk5Bhro3Tbua6KwoTests90", // integration_test/test/preload_test.dart
      @"testReducedjourneyWhennetworkchangepresentThendisplayswithkmBg8F0Zcws1Ha8Umhb6XjTests356", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedjourneyWhenloadedThendisplaystraininformationVaibsv3Jaxe2IslmbuphTests626", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedjourneyWhenshuntingmovementjourneyThendisplaystraininformationHrt2S4Ied0Ewnedvvs14Tests264", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedjourneyWhenstoppingandpassingpointsThendisplayscorrectly49Ntmpongah3D2TefradTests626", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedjourneyWhenduplicatedasrThendisplaysonlyoncePczskx79Ogmg0Q3Pqn5DTests626", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedjourneyWhenloadedThendisplaysoperationaltimesTk4Dmru7Xmiasig1ZnwdTests84", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedjourneyWhenroutevariantspresentThendisplaysexpectedviatexts243626Psbihpnaiwu3Ewwui8Wo", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedjourneyWhenfilterstoggledThendisplaysexpectedfiltereddata8Gtxulilune990Rfs6TqTests243", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedjourneyWhenfilteroptionhasnoelementsThenfilteroptionisnotdisplayedNcea7Zkv9QkrskpnebmvTests243", // integration_test/test/reduced_journey_table_test.dart
      @"testReducedjourneyWhenfilterhasnodataThenfilterbarisnotdisplayedZp6YldzlciyrywglwxfyTests243", // integration_test/test/reduced_journey_table_test.dart
      @"testRuindicationsWhenshouldreturnmockdataThenindicationsareshownYejd2Tuqjowvkqcf7RycTests700", // integration_test/test/ru_indications_test.dart
      @"testRuindicationsWhenlongtextwithlinkThenshowmoreisvisibleGiyge5R7Ypqaht07DghwTests700", // integration_test/test/ru_indications_test.dart
      @"testRuindicationsWhenlongtextwithmarkdownlinkThenlinklabelisrenderedGuprxy8Bqyidlcgugxu0Tests700", // integration_test/test/ru_indications_test.dart
      @"testRuindicationsWhenlongtextexpandedThenfullcontentisvisibleR66Dkes5LmwlwiwhevsvTests700", // integration_test/test/ru_indications_test.dart
      @"testServicepointmodalWhenbahnhofportallinktappedThenopensexpectedurlHjoshoannns1Uizv1PizTests1485", // integration_test/test/service_point_modal_test.dart
      @"testServicepointmodalWhenopenedThenhideskilometrecolumnZnzvrpa4V1Zbwe1GlnmiTests497", // integration_test/test/service_point_modal_test.dart
      @"testServicepointmodalWheninteractedThenopensandclosescorrectlyBulpri837Zbdhbf9Ozo1Tests497", // integration_test/test/service_point_modal_test.dart
      @"testServicepointmodalWhensamecelltappedtwiceThenclosesmodalBlzzhmecrmoz03Ghc4KoTests1875", // integration_test/test/service_point_modal_test.dart
      @"testServicepointmodalWhenradiochanneltappedtwiceThenclosesmodal47Updax6Hsiyclucw05KTests1875", // integration_test/test/service_point_modal_test.dart
      @"testServicepointmodalWhendifferentservicepointtappedThenswitcheswithoutclosingYnah8X76Zb856Tyrx9MjTests1875", // integration_test/test/service_point_modal_test.dart
      @"testServicepointmodalWhenactivetabreselectedThendoesnothingQd8Zin2Izxvs5Dgo9ZjdTests1875", // integration_test/test/service_point_modal_test.dart
      @"testServicepointmodalWhenopenedThencollapsesheaderbuttonsQ7V14S34B9G0J5OvssvyTests497", // integration_test/test/service_point_modal_test.dart
      @"testServicepointmodalWhendataavailableThenshowsonlyrelevanttabsHcumxsq54On6AaciawkyTests1040497", // integration_test/test/service_point_modal_test.dart
      @"testServicepointmodalWhentabchangedThendisplayscorrectcontent7Umiwrpg9Zo3Wq1YohzfTests497", // integration_test/test/service_point_modal_test.dart
      @"testServicepointmodalWhentimeoutThenclosesautomaticallyL3Ivfdwk1Kz8T4Zbo1CwTests497", // integration_test/test/service_point_modal_test.dart
      @"testServicepointmodalWhenadvancementpausedThenclosesaftertimeoutPzmrskglsqo1CxxdrssfTests497", // integration_test/test/service_point_modal_test.dart
      @"testGraduatedspeedWhenpresentThendisplaysinfodetails4Mjc7Eegubicosw69JyaTests231", // integration_test/test/service_point_modal_test.dart
      @"testCommunicationtabWhenopenedThendisplaysnetworkandradiochannels02Dnnckadwrripfdp8RgTests229", // integration_test/test/service_point_modal_test.dart
      @"testCommunicationtabWhenopenedfromothertabThenshowsinformationPnui8Yhc85RazhmisaezTests229", // integration_test/test/service_point_modal_test.dart
      @"testCommunicationtabWhendepartureauthorizationpresentThendisplaysinmodal02Daropx5Oqot03Mcvb8Tests226", // integration_test/test/service_point_modal_test.dart
      @"testLocalregulationtabWhenpresentThenshowstabG2Kzy4GafaapiqmdgefgTests95", // integration_test/test/service_point_modal_test.dart
      @"testLocalregulationtabWhentabchangedThenupdatesdisplayLoewpfso4Qcapw2AvhuzTests95", // integration_test/test/service_point_modal_test.dart
      @"testLocalregulationtabWhenopenedThenshowswebviewCccuxowsksjlpqmqsxttTests95", // integration_test/test/service_point_modal_test.dart
      @"testServicepointmodalWhenmodalopenThenshowsshortsignalnamesD56Hz2Flgtw6Tj4Ome9VTests980", // integration_test/test/service_point_modal_test.dart
      @"testServicepointmodalWhennavigatedandreturnedThenstaysdisplayed1Qsvqp8Jis2Qsg4DklioTests497", // integration_test/test/service_point_modal_test.dart
      @"testSettingsWhenopenedThenshowsheaderinformationAsz1Ts4Ku7Nf5Oxr8IprTests427", // integration_test/test/settings_test.dart
      @"testSettingsWhencompanyselectedandunselectedThendisplaysselectionO7Wl0Fgvcl2Yp91Sbko3Tests427", // integration_test/test/settings_test.dart
      @"testSettingsWhentoursystemselectedThendisplaysselectionVg694P8Aplw0HpthokayTests427", // integration_test/test/settings_test.dart
      @"testSettingsWhendecisivegradientdisabledThenhidesgradientsDnfjnfphhpuoojuvfnreTests583", // integration_test/test/settings_test.dart
      @"testSettingsWhenkmheaderclickedwithgradienthiddenThentogglesdisplayLdw7Fzgpdn3ZytjjtduaTests583", // integration_test/test/settings_test.dart
      @"testSettingsWhenstationsignalhiddenThenhidescorrectsignalsWfjtznpiekwtpvmb9Rw0Tests811", // integration_test/test/settings_test.dart
      @"testSettingsWhenstationsignalhiddenThenchevronpositionscorrectly3Xkydx4SwtjlxynqgmoiTests811", // integration_test/test/settings_test.dart
      @"testSettingsWhenstationsignalstoggledThenhidesbutkeepsetcsstopsignsVxfgyvh5Oeitemad3EvqTests16281484", // integration_test/test/settings_test.dart
      @"testSettingsWhenetcsconventionaltoggledThenhidesonlyconventionalstopsignD70X81Okbp7Mf1FptjejTests16281484", // integration_test/test/settings_test.dart
      @"testSettingsWhenetcsextendedtoggledThenhidesonlyextendedstopsignsWyfgcqfbagrteltqj00QTests16281484", // integration_test/test/settings_test.dart
      @"testSettingsWhenbothetcstoggledoffThenhidesalletcsstopsignsX7Guyj0Rrgj3KycghzapTests16281484", // integration_test/test/settings_test.dart
      @"testShorttermchangesWhenpresentThendisplaysallcorrectlyinjourneytableRpkzrlcoufvvodilaj3HTests99", // integration_test/test/short_term_changes_test.dart
      @"testShorttermchangesWhenpresentThendisplaysallcorrectlyinflapKshbuncrkalvbi9O4DavTests99", // integration_test/test/short_term_changes_test.dart
      @"testSuspicioussegmentWhenloadedThenshowsrowsandnotificationanddismissesEhjmbx24Ewgwgg10BezqTests409", // integration_test/test/suspicious_segment_test.dart
      @"testSuspicioussegmentWhenallpassedThendisappearsandreappearsonupdateObl4K6Vmunfhbxfuzby8Tests409", // integration_test/test/suspicious_segment_test.dart
      @"testSuspicioussegmentWhenjourneyupdatedThenshowsnotificationCqaskmxsyq2Yekuchh6YTests409", // integration_test/test/suspicious_segment_test.dart
      @"testToursystemWhennotconfiguredThenhidesbuttonsJpxguirh7Wxqnvb04ZmjTests96", // integration_test/test/tour_system_link_test.dart
      @"testToursystemWhenconfiguredThenshowsbuttonsDnnl6Kr0Cr51Ghfbwop5Tests96", // integration_test/test/tour_system_link_test.dart
      @"testToursystemWhenpositionchangesThenupdatesbuttonvisibilityLshbn4Urksjx7Napw9GoTests96", // integration_test/test/tour_system_link_test.dart
      @"testTrainsearchWhenpageloadedThenshowsdefaultvaluesYjslvmx6Prhdbt3GnctgTests92", // integration_test/test/train_search_test.dart
      @"testTrainsearchWhencompanyselectionopenedThenshowsoptions4V8Lvliaxkstk9LkhcfvTests92", // integration_test/test/train_search_test.dart
      @"testTrainsearchWhenrufilterenteredThenfiltersresultsK9Lxjibbfwa0SakjbxjuTests596", // integration_test/test/train_search_test.dart
      @"testTrainsearchWhennotrainnumberenteredThendisablesbutton3JeyvxxjnxvgfeaoufjkTests92", // integration_test/test/train_search_test.dart
      @"testTrainsearchWhenyesterdayselectedThenshowswarningRh6SvdbhmuibnydfpxfoTests92", // integration_test/test/train_search_test.dart
      @"testTrainsearchWhendaybeforeyesterdayThencannotselectT4Mnyzwoakpfwz6CypkaTests92", // integration_test/test/train_search_test.dart
      @"testTrainsearchWhenjpunavailableThenshowserrorIpmnmrosspbbs6AhadtkTests92", // integration_test/test/train_search_test.dart
      @"testTrainsearchWhenerrorfromsferaThendisplayserrorcode9Uiii436R7Pmuxwlx6ZrTests652", // integration_test/test/train_search_test.dart
      @"testTrainsearchWhenmultiplecompanymatchesThenshowsselectionEdyqlmrib617Kcxr5XxnTests702703", // integration_test/test/train_search_test.dart
      @"testTrainsearchWhenlastcompanycoderememberedThenautoselectsG6T83P9J45Q6Kft4Y70FTests702", // integration_test/test/train_search_test.dart
      @"testTrainsearchWhennocompanymatchThenshowsnoresultmessageWq4Rtb8Lzngl5Hw7Dbq0Tests702", // integration_test/test/train_search_test.dart
      @"testWarnappWhensignalisredThentriggerswarningFyc1Jkh9Cdcbv12Psb7QTests98", // integration_test/test/warnapp_test.dart
      @"testWarnappWhenuirebuiltThennotificationnotreappearingUotbx3Swk0Erq5UknypqTests98", // integration_test/test/warnapp_test.dart
      @"testWarnappWhenmaneuverbuttontappedThenactivatesmaneuvermodeFzvou1Fqoyjnn2Es2No0Tests98", // integration_test/test/warnapp_test.dart
      @"testWarnappWheninmaneuvermodeThendoesnottriggerL1Acz9Qnjvnywflskh9YTests98", // integration_test/test/warnapp_test.dart
      @"testWarnappWhensignalisgreenThendoesnottrigger8Evsobx4Adhhzex7HtwvTests98", // integration_test/test/warnapp_test.dart
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
