import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/model/short_term_change_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/short_term_change_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/main_header_box.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ShortTermChangeHeaderBoxFlap extends StatelessWidget {
  static double get height => 36.0;

  static Key get hasShortTermChangeKey => Key('flapHasShortTermChangeKey');

  static Key get singleShortTermChangeKey => Key('flapSingleShortTermChangeKey');

  static Key get multipleShortTermChangeKey => Key('flapMultipleShortTermChangeKey');

  const ShortTermChangeHeaderBoxFlap({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeUtil.getColor(context, SBBColors.turquoise, SBBColors.turquoiseDark);
    return SizedBox(
      height: MainHeaderBox.height + height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: Align(
          alignment: .bottomLeft,
          child: _content(context),
        ),
      ),
    );
  }

  Widget? _content(BuildContext context) {
    final vm = context.read<ShortTermChangeViewModel>();
    return StreamBuilder(
      stream: vm.model,
      initialData: vm.modelValue,
      builder: (context, asyncSnap) {
        final model = asyncSnap.requireData;
        if (model is NoShortTermChanges) return SizedBox.shrink();

        return Padding(
          key: hasShortTermChangeKey,
          padding: const EdgeInsets.only(left: SBBSpacing.medium, bottom: SBBSpacing.xSmall),
          child: Row(
            mainAxisSize: .min,
            spacing: SBBSpacing.xSmall,
            children: [
              _warnIcon(),
              Text(
                key: model is SingleShortTermChange ? singleShortTermChangeKey : multipleShortTermChangeKey,
                model.toLocalizedDisplayString(context),
                style: sbbTextStyle.small.boldStyle.copyWith(color: SBBColors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _warnIcon() {
    return SvgPicture.asset(
      AppAssets.iconSignExclamationPoint,
      colorFilter: ColorFilter.mode(SBBColors.white, .srcIn),
    );
  }
}

extension _ShortTermChangeModelX on ShortTermChangeModel {
  String toLocalizedDisplayString(BuildContext context) {
    return switch (this) {
      NoShortTermChanges() => '',
      SingleShortTermChange(shortTermChangeType: final shortTermChangeType, servicePointName: final servicePointName) =>
        switch (shortTermChangeType) {
          ShortTermChangeType.endDestination => context.l10n.w_short_term_change_headerbox_flap_end_destination_change(
            servicePointName ?? '',
          ),
          ShortTermChangeType.trainRunRerouting => context.l10n.w_short_term_change_headerbox_flap_train_run_rerouting,
          ShortTermChangeType.stop2Pass => context.l10n.w_short_term_change_headerbox_stop_2_pass(
            servicePointName ?? '',
          ),
          ShortTermChangeType.pass2Stop => context.l10n.w_short_term_change_headerbox_pass_2_stop(
            servicePointName ?? '',
          ),
        },
      MultipleShortTermChanges() => context.l10n.w_short_term_change_headerbox_flap_multiple_changes,
    };
  }
}
