import 'dart:async';

import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_model.dart';
import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class TimeContainer extends StatelessWidget {
  static const Key delayKey = Key('delayTextKey');

  const TimeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      padding: const EdgeInsets.all(sbbDefaultSpacing),
      useShadow: false,
      child: SizedBox(
        width: 124.0,
        height: 112.0,
        child: _currentTimeAndOptionalDelay(context),
      ),
    );
  }

  Widget _currentTimeAndOptionalDelay(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Flexible(child: _currentTime()),
      _divider(),
      Flexible(child: _delay(context)),
    ],
  );

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.5),
      child: Divider(height: 1.0, color: SBBColors.cloud),
    );
  }

  Widget _delay(BuildContext context) {
    final viewModel = context.read<PunctualityViewModel>();
    return StreamBuilder<PunctualityModel>(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.data;
        if (model == null || model is Hidden) return SizedBox.expand();

        final TextStyle resolvedStyle = _resolvedDelayStyle(model, context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            sbbDefaultSpacing * 0.5,
            0.0,
            sbbDefaultSpacing * 0.5,
            sbbDefaultSpacing * 0.5,
          ),
          child: Text(model.delayString, style: resolvedStyle, key: TimeContainer.delayKey),
        );
      },
    );
  }

  TextStyle _resolvedDelayStyle(PunctualityModel model, BuildContext context) => switch (model) {
    final Stale _ => DASTextStyles.xLargeLight.copyWith(
      color: ThemeUtil.getColor(
        context,
        SBBColors.graphite,
        SBBColors.granite,
      ),
    ),
    final Visible _ || final Hidden _ => DASTextStyles.xLargeLight,
  };

  Widget _currentTime() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 200)),
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            sbbDefaultSpacing * 0.5,
            sbbDefaultSpacing * 0.5,
            sbbDefaultSpacing * 0.5,
            0,
          ),
          child: Text(
            DateFormat('HH:mm:ss').format(clock.now()),
            style: DASTextStyles.xLargeBold,
          ),
        );
      },
    );
  }
}
