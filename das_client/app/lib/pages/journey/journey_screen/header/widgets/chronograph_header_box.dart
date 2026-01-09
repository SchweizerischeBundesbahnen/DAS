import 'package:app/pages/journey/journey_screen/header/view_model/chronograph_view_model.dart';
import 'package:app/pages/journey/journey_screen/model/punctuality_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

const double _width = 124.0;
const double _height = 112.0;
const Duration _animationDuration = Duration(milliseconds: 250);

class ChronographHeaderBox extends StatelessWidget {
  static const Key punctualityTextKey = Key('punctualityTextKey');
  static const Key currentTimeTextKey = Key('currentTimeTextKey');

  const ChronographHeaderBox({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      padding: const .all(sbbDefaultSpacing),
      child: SizedBox(
        width: _width,
        height: _height,
        child: body(context),
      ),
    );
  }

  Widget body(BuildContext context) => Column(
    mainAxisAlignment: .start,
    crossAxisAlignment: .end,
    children: [
      Flexible(child: _currentTime(context)),
      Divider(height: sbbDefaultSpacing, color: SBBColors.cloud),
      Flexible(child: _delay(context)),
    ],
  );

  Widget _delay(BuildContext context) {
    final viewModel = context.read<ChronographViewModel>();
    return StreamBuilder<PunctualityModel>(
      stream: viewModel.punctualityModel,
      initialData: viewModel.punctualityModelValue,
      builder: (context, snapshot) {
        final model = snapshot.data;
        final showPunctuality = (model != null && model is! Hidden);

        final TextStyle resolvedStyle = _resolvedDelayStyle(model, context);
        return AnimatedOpacity(
          opacity: showPunctuality ? 1.0 : 0.0,
          duration: _animationDuration,
          child: Padding(
            padding: const .all(sbbDefaultSpacing * 0.5),
            child: Text(
              key: showPunctuality ? ChronographHeaderBox.punctualityTextKey : null,
              model?.formattedDelay ?? '',
              style: resolvedStyle,
            ),
          ),
        );
      },
    );
  }

  TextStyle _resolvedDelayStyle(PunctualityModel? model, BuildContext context) => switch (model) {
    final Stale _ => DASTextStyles.xLargeRoman.copyWith(
      color: ThemeUtil.getColor(
        context,
        SBBColors.graphite,
        SBBColors.white,
      ),
    ),
    final Visible _ || final Hidden _ || null => DASTextStyles.xLargeLight,
  };

  Widget _currentTime(BuildContext context) {
    final viewModel = context.read<ChronographViewModel>();
    return StreamBuilder(
      stream: viewModel.formattedWallclockTime,
      initialData: viewModel.formattedWallclockTimeValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.expand();

        return Padding(
          padding: const .all(sbbDefaultSpacing * 0.5),
          child: Text(snapshot.requireData, key: currentTimeTextKey, style: DASTextStyles.xLargeBold),
        );
      },
    );
  }
}
