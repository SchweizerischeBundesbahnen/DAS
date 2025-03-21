import 'package:das_client/app/bloc/ux_testing_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/departure_process_modal_sheet.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/model/journey/koa_state.dart';
import 'package:das_client/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class KoaNotification extends StatelessWidget {
  const KoaNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final uxTestingCubit = context.read<UxTestingCubit>();

    return StreamBuilder<KoaState>(
      stream: uxTestingCubit.koaStateStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == KoaState.waitHide) return Container();

        return Container(
          margin: EdgeInsets.fromLTRB(sbbDefaultSpacing * 0.5, 0, sbbDefaultSpacing * 0.5, sbbDefaultSpacing * 0.5),
          child: snapshot.data == KoaState.wait ? _waitWidget(context) : _waitCanceledWidget(context),
        );
      },
    );
  }

  Widget _waitWidget(BuildContext context) {
    return SBBPromotionBox.custom(
      leading: SvgPicture.asset(
        AppAssets.iconKoaWait,
        colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
      ),
      content: Text(
        context.l10n.w_koa_notification_wait,
        style: DASTextStyles.mediumRoman,
      ),
      badgeText: context.l10n.w_koa_notification_title,
      trailing: _trailingButton(context),
    );
  }

  Widget _waitCanceledWidget(BuildContext context) {
    return SBBPromotionBox.custom(
      leading: Icon(
        SBBIcons.circle_tick_medium,
        color: SBBColors.black
      ),
      content: Text(
        context.l10n.w_koa_notification_wait_canceled,
        style:
            DASTextStyles.mediumRoman.copyWith(color: SBBColors.black),
      ),
      badgeText: context.l10n.w_koa_notification_title,
      trailing: _trailingButton(context),
      gradientColors: [SBBColors.cloud, SBBColors.milk, SBBColors.milk, SBBColors.cloud],
    );
  }

  Widget _trailingButton(BuildContext context) {
    return SBBTertiaryButtonSmall(
      label: context.l10n.w_koa_notification_departure_process,
      onPressed: () {
        showDepartureProcessModalSheet(context);
      },
    );
  }
}
