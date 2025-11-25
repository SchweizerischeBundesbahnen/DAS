import 'package:app/i18n/i18n.dart';
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
    return Center(child: Text(context.l10n.p_break_load_slip_page_title));
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
