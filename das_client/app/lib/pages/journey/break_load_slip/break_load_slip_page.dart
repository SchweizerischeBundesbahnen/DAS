import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_brake_details.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_buttons.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_hauled_load_details.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_header.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_other_data.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_special_restrictions.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_train_details.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class BreakLoadSlipPage extends StatelessWidget {
  const BreakLoadSlipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return SBBHeader(
      title: context.l10n.p_break_load_slip_page_title,
      leadingWidget: _DismissButton(),
      // Removes SBB Icon in AppBar
      actions: [Container()],
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      spacing: sbbDefaultSpacing,
      children: [
        BreakLoadSlipHeader(),
        SingleChildScrollView(
          child: Column(
            spacing: sbbDefaultSpacing,
            children: [
              BreakLoadSlipTrainDetails(),
              _otherDataAndBrakeDetailsRow(context),
              _hauledLoadSpecialAndButtonRow(context),
            ],
          ),
        ),
      ],
    );
  }

  Row _otherDataAndBrakeDetailsRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(left: sbbDefaultSpacing, right: sbbDefaultSpacing * 0.5),
            child: BreakLoadSlipOtherData(),
          ),
        ),
        Expanded(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.only(left: sbbDefaultSpacing * 0.5, right: sbbDefaultSpacing),
            child: BreakLoadSlipBrakeDetails(),
          ),
        ),
      ],
    );
  }

  Row _hauledLoadSpecialAndButtonRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(left: sbbDefaultSpacing, right: sbbDefaultSpacing * 0.5),
            child: BreakLoadSlipHauledLoadDetails(),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(left: sbbDefaultSpacing * 0.5, right: sbbDefaultSpacing * 0.5),
            child: BreakLoadSlipSpecialRestrictions(),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.only(left: sbbDefaultSpacing * 0.5, right: sbbDefaultSpacing),
            child: BreakLoadSlipButtons(),
          ),
        ),
      ],
    );
  }
}

class _DismissButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(SBBIcons.chevron_left_small),
    onPressed: () {
      if (context.mounted) {
        context.router.pop();
      }
    },
  );
}
