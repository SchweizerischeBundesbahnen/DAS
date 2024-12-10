import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:das_client/model/journey/journey.dart';

class TimeContainer extends StatelessWidget {
  const TimeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.trainJourneyCubit;

    return StreamBuilder<Journey?>(
        stream: bloc.journeyStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: SBBLoadingIndicator(),
            );
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
            child: SizedBox(
              width: 124.0,
              height: 112.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '05:43:00',
                    style: SBBTextStyles.largeBold.copyWith(fontSize: 24.0),
                  ),
                  _divider(),
                  _punctualityDisplay(journey),
                ],
              ),
            ),
          );
        });
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.5),
      child: Divider(height: 1.0, color: SBBColors.cloud),
    );
  }

  Widget _punctualityDisplay(Journey journey) {

    return Text(
      _loadTimeDifference(), style: SBBTextStyles.largeLight.copyWith(fontSize: 24.0),
    );

    //The code below is for the case when VPro is finally in the model
    /* final bool hasVPro = journey.metadata.additionalSpeedRestrictions.any((restriction) => restriction.speed != null);

    return Text(
      hasVPro ? _loadTimeDifference() : '',
      style: SBBTextStyles.largeLight.copyWith(fontSize: 24.0),
    );
     */
  }

  String _loadTimeDifference(){
    return '00:00';
  }
}

