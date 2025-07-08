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

const double _width = 124.0;
const double _height = 112.0;
const Duration _animationDuration = Duration(milliseconds: 250);

class DASChronograph extends StatelessWidget {
  static const Key punctualityTextKey = Key('punctualityTextKey');

  const DASChronograph({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      padding: const EdgeInsets.all(sbbDefaultSpacing),
      useShadow: false,
      child: SizedBox(
        width: _width,
        height: _height,
        child: body(context),
      ),
    );
  }

  Widget body(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Flexible(child: _currentTime()),
      Divider(height: sbbDefaultSpacing, color: SBBColors.cloud),
      Flexible(child: _delay(context)),
    ],
  );

  Widget _delay(BuildContext context) {
    final viewModel = context.read<PunctualityViewModel>();
    return StreamBuilder<PunctualityModel>(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.data;
        final showPunctuality = (model != null && model is! Hidden);

        final TextStyle resolvedStyle = _resolvedDelayStyle(model, context);
        return AnimatedOpacity(
          opacity: showPunctuality ? 1.0 : 0.0,
          duration: _animationDuration,
          child: Padding(
            padding: const EdgeInsets.all(sbbDefaultSpacing * 0.5),
            child: Text(
              key: showPunctuality ? DASChronograph.punctualityTextKey : null,
              model?.delay ?? '',
              style: resolvedStyle,
            ),
          ),
        );
      },
    );
  }

  TextStyle _resolvedDelayStyle(PunctualityModel? model, BuildContext context) => switch (model) {
    final Stale _ => DASTextStyles.xLargeLight.copyWith(
      color: ThemeUtil.getColor(
        context,
        SBBColors.graphite,
        SBBColors.granite,
      ),
    ),
    final Visible _ || final Hidden _ || null => DASTextStyles.xLargeLight,
  };

  Widget _currentTime() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 200)),
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.all(sbbDefaultSpacing * 0.5),
          child: Text(
            DateFormat('HH:mm:ss').format(clock.now()),
            style: DASTextStyles.xLargeBold,
          ),
        );
      },
    );
  }
}
