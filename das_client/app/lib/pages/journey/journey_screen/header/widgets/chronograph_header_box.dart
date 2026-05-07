import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/chronograph_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/departure_process_warning_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/punctuality_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

const Size _fixedSize = Size(180, 144);
const Duration _animationDuration = Duration(milliseconds: 250);

class ChronographHeaderBox extends StatelessWidget {
  static const Key punctualityTextKey = Key('punctualityTextKey');
  static const Key currentTimeTextKey = Key('currentTimeTextKey');
  static const Key warningKey = Key('ChronographHeaderboxWarningKey');

  const ChronographHeaderBox({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<DepartureProcessWarningViewModel>();
    return ConstrainedBox(
      constraints: BoxConstraints.tight(_fixedSize),
      child: StreamBuilder(
        stream: vm.showChronographWarning,
        initialData: vm.showChronographWarningValue,
        builder: (context, snap) {
          return SBBContentBox(
            padding: snap.requireData ? .zero : const .all(SBBSpacing.medium),
            child: snap.requireData ? warningBody(context) : body(context),
          );
        },
      ),
    );
  }

  Widget body(BuildContext context) => Column(
    mainAxisAlignment: .start,
    crossAxisAlignment: .end,
    children: [
      Flexible(child: _currentTime(context)),
      Divider(height: SBBSpacing.medium, color: SBBColors.cloud),
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
            padding: const .all(SBBSpacing.xSmall),
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
    final Stale _ => sbbTextStyle.romanStyle.xLarge.copyWith(
      color: ThemeUtil.getColor(
        context,
        SBBColors.graphite,
        SBBColors.white,
      ),
    ),
    final Visible _ || final Hidden _ || null => sbbTextStyle.lightStyle.xLarge,
  };

  Widget _currentTime(BuildContext context) {
    final viewModel = context.read<ChronographViewModel>();
    return StreamBuilder(
      stream: viewModel.formattedWallclockTime,
      initialData: viewModel.formattedWallclockTimeValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.expand();

        return Padding(
          padding: const .all(SBBSpacing.xSmall),
          child: Text(snapshot.requireData, key: currentTimeTextKey, style: sbbTextStyle.boldStyle.xLarge),
        );
      },
    );
  }

  Widget warningBody(BuildContext context) {
    return Container(
      key: warningKey,
      color: ThemeUtil.getColor(context, SBBColors.red, SBBColors.red85),
      child: Center(
        child: Text(
          context.l10n.w_chronograph_no_authorisation_warning,
          maxLines: 2,
          style: SBBTextStyles.largeBold.copyWith(color: SBBColors.white),
          textAlign: .center,
        ),
      ),
    );
  }
}
