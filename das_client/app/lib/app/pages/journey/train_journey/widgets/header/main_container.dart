import 'package:app/app/bloc/train_journey_cubit.dart';
import 'package:app/app/extension/ru_extension.dart';
import 'package:app/app/i18n/i18n.dart';
import 'package:app/app/pages/journey/train_journey/widgets/header/battery_status.dart';
import 'package:app/app/pages/journey/train_journey/widgets/header/departure_authorization.dart';
import 'package:app/app/pages/journey/train_journey/widgets/header/extended_menu.dart';
import 'package:app/app/pages/journey/train_journey/widgets/header/radio_channel.dart';
import 'package:app/app/pages/journey/train_journey/widgets/header/start_pause_button.dart';
import 'package:app/app/pages/journey/train_journey/widgets/header/theme_button.dart';
import 'package:app/app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/app/widgets/assets.dart';
import 'package:app/app/widgets/das_text_styles.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.trainJourneyCubit;

    return StreamBuilder(
      stream: CombineLatestStream.list([bloc.journeyStream, bloc.settingsStream]),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?[0] == null || snapshot.data?[1] == null) {
          return Center(child: SBBLoadingIndicator());
        }
        final journey = snapshot.data![0] as Journey;
        final settings = snapshot.data![1] as TrainJourneySettings;

        return SBBGroup(
          padding: const EdgeInsets.all(sbbDefaultSpacing),
          useShadow: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _topHeaderRow(context, journey.metadata, settings),
              _divider(),
              _bottomHeaderRow(context, journey.metadata),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomHeaderRow(BuildContext context, Metadata metadata) {
    return SizedBox(
      height: 48.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RadioChannel(metadata: metadata),
          SizedBox(width: sbbDefaultSpacing * 0.5),
          DepartureAuthorization(),
          Spacer(),
          _trainJourneyText(context),
          BatteryStatus(),
        ],
      ),
    );
  }

  Widget _trainJourneyText(BuildContext context) {
    final state = context.trainJourneyCubit.state;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing * 0.5),
      child: Text(
        state is TrainJourneyLoadedState
            ? '${state.trainIdentification.trainNumber} ${state.trainIdentification.ru.displayText(context)}'
            : '',
        style: DASTextStyles.mediumRoman,
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.5),
      child: Divider(height: 1.0, color: SBBColors.cloud),
    );
  }

  Widget _topHeaderRow(BuildContext context, Metadata metadata, TrainJourneySettings settings) {
    return SizedBox(
      height: 48.0,
      child: Row(
        children: [
          SvgPicture.asset(
            AppAssets.iconHeaderStop,
            colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
          ),
          Expanded(child: _servicePointName(context, metadata)),
          _buttonArea(settings),
        ],
      ),
    );
  }

  Widget _servicePointName(BuildContext context, Metadata metadata) {
    return Padding(
      padding: const EdgeInsets.only(left: sbbDefaultSpacing * 0.5),
      child: Text(
        metadata.nextStop?.name ?? context.l10n.c_unknown,
        style: DASTextStyles.xLargeLight,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buttonArea(TrainJourneySettings settings) {
    return Row(
      spacing: sbbDefaultSpacing * 0.5,
      children: [
        ThemeButton(),
        StartPauseButton(automaticAdvancementActive: settings.isAutoAdvancementEnabled),
        ExtendedMenu(),
      ],
    );
  }
}
