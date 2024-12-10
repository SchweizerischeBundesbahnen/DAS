import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/departure_authorization.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/radio_channel.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/widget_extensions.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:das_client/model/journey/journey.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.trainJourneyCubit;

    return StreamBuilder<Journey?>(
        stream: bloc.journeyStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            //center
            return SBBLoadingIndicator();
          }
          final Journey journey = snapshot.data!;

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
                _topHeaderRow(context, journey),
                _divider(),
                _bottomHeaderRow(),
              ],
            ),
          );
        });
  }

  Widget _bottomHeaderRow() {
    return const SizedBox(
      height: 48.0,
      child: Row(
        children: [
          RadioChannel(),
          SizedBox(width: 48.0),
          DepartureAuthorization(),
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

  Widget _topHeaderRow(BuildContext context, Journey journey) {
    return SizedBox(
      height: 48.0,
      child: Row(
        children: [
          SvgPicture.asset(AppAssets.iconHeaderStop),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: sbbDefaultSpacing * 0.5),
              child: Text(journey.metadata.nextStop?.name.localized ?? context.l10n.c_unknown,
                  style: SBBTextStyles.largeLight.copyWith(fontSize: 24.0)),
            ),
          ),
          _buttonArea(),
        ],
      ),
    );
  }

  Widget _buttonArea() {
    return Builder(builder: (context) {
      return Row(
        children: [
          SBBTertiaryButtonLarge(
            label: context.l10n.p_train_journey_header_button_dark_theme,
            icon: SBBIcons.moon_small,
            onPressed: () {},
          ),
          SBBTertiaryButtonLarge(
            label: context.l10n.p_train_journey_header_button_pause,
            icon: SBBIcons.pause_small,
            onPressed: () {},
          ),
          SBBIconButtonLarge(
            icon: SBBIcons.context_menu_small,
            onPressed: () {},
          ),
        ].withSpacing(width: sbbDefaultSpacing * 0.5),
      );
    });
  }
}
