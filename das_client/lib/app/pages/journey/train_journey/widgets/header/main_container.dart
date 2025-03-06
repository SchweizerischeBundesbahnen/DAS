import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/battery_status.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/departure_authorization.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/extended_menu.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/radio_channel.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/model/journey/communication_network_change.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.trainJourneyCubit;

    return StreamBuilder<List<dynamic>>(
        stream: CombineLatestStream.list([bloc.journeyStream, bloc.settingsStream]),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?[0] == null || snapshot.data?[1] == null) {
            return Center(
              child: SBBLoadingIndicator(),
            );
          }
          final journey = snapshot.data![0] as Journey;
          final settings = snapshot.data![1] as TrainJourneySettings;

          return SBBGroup(
            margin: const EdgeInsetsDirectional.fromSTEB(
              sbbDefaultSpacing * 0.5,
              0,
              sbbDefaultSpacing * 0.5,
              sbbDefaultSpacing,
            ),
            padding: const EdgeInsets.all(sbbDefaultSpacing),
            useShadow: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topHeaderRow(context, journey, settings),
                _divider(),
                _bottomHeaderRow(journey.metadata),
              ],
            ),
          );
        });
  }

  Widget _bottomHeaderRow(Metadata metadata) {
    final communicationNetworkType = metadata.nextStop != null
        ? metadata.communicationNetworkChanges.appliesToOrder(metadata.nextStop!.order)
        : null;
    return SizedBox(
      height: 48.0,
      child: Row(
        children: [
          RadioChannel(communicationNetworkType: communicationNetworkType),
          SizedBox(width: sbbDefaultSpacing * 0.5),
          DepartureAuthorization(),
          Spacer(),
          BatteryStatus(),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.5),
      child: Divider(height: 1.0, color: SBBColors.cloud),
    );
  }

  Widget _topHeaderRow(BuildContext context, Journey journey, TrainJourneySettings settings) {
    return SizedBox(
      height: 48.0,
      child: Row(
        children: [
          SvgPicture.asset(AppAssets.iconHeaderStop),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: sbbDefaultSpacing * 0.5),
              child: Text(
                journey.metadata.nextStop?.name.localized ?? context.l10n.c_unknown,
                style: DASTextStyles.xLargeLight,
              ),
            ),
          ),
          _buttonArea(settings),
        ],
      ),
    );
  }

  Widget _buttonArea(TrainJourneySettings settings) {
    return Builder(builder: (context) {
      return Row(
        spacing: sbbDefaultSpacing * 0.5,
        children: [
          SBBTertiaryButtonLarge(
            label: context.l10n.p_train_journey_header_button_dark_theme,
            icon: SBBIcons.moon_small,
            onPressed: () {},
          ),
          if (settings.automaticAdvancementActive)
            SBBTertiaryButtonLarge(
              label: context.l10n.p_train_journey_header_button_pause,
              icon: SBBIcons.pause_small,
              onPressed: () {
                context.trainJourneyCubit.setAutomaticAdvancement(false);
              },
            ),
          if (!settings.automaticAdvancementActive)
            SBBTertiaryButtonLarge(
              label: context.l10n.p_train_journey_header_button_start,
              icon: SBBIcons.play_small,
              onPressed: () {
                context.trainJourneyCubit.setAutomaticAdvancement(true);
              },
            ),
          ExtendedMenu(),
        ],
      );
    });
  }
}
