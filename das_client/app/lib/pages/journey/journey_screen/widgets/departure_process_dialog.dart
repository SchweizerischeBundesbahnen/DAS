import 'package:app/i18n/src/build_context_x.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/koa_notification.dart';
import 'package:app/pages/journey/journey_screen/view_model/checklist_departure_process_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/checklist_departure_process_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/ux_testing_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

Future<void> showDepartureProcessDialog(BuildContext context) {
  final uxTestingVM = context.read<UxTestingViewModel>();
  final departureProcessChecklistVM = context.read<ChecklistDepartureProcessViewModel>();

  return showDialog<void>(
    useRootNavigator: false,
    context: context,
    builder: (context) {
      return Provider.value(
        value: uxTestingVM,
        child: Provider.value(
          value: departureProcessChecklistVM,
          child: DepartureProcessDialog(),
        ),
      );
    },
  );
}

class DepartureProcessDialog extends StatelessWidget {
  static const dialogKey = Key('DepartureProcessDialogKey');

  static const _maxWidth = 352.0;

  const DepartureProcessDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ChecklistDepartureProcessViewModel>();
    return StreamBuilder(
      stream: vm.model,
      initialData: vm.modelValue,
      builder: (context, snap) {
        final data = snap.requireData;
        if (data is ChecklistDepartureProcessDisabled) return SizedBox.shrink();

        return Dialog(
          key: dialogKey,
          backgroundColor: ThemeUtil.getBackgroundColor(context),
          shape: RoundedRectangleBorder(borderRadius: .circular(SBBSpacing.medium)),
          constraints: BoxConstraints(maxWidth: _maxWidth),
          child: Container(
            padding: const EdgeInsets.all(SBBSpacing.medium).copyWith(top: SBBSpacing.xSmall),
            child: Column(
              mainAxisSize: .min,
              children: [
                _titleRow(context),
                if (data is CustomerOrientedDepartureChecklist) ..._koaNotification(),
                _nextStop(context, data),
                _staticDepartureProcessChecklist(context, data),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _titleRow(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: .infinity, minHeight: 64.0),
      child: Align(
        alignment: .centerLeft,
        child: Row(
          children: [
            Expanded(child: Text('Abfahrprozess', style: SBBTextStyles.largeLight)), // TODO: intl
            SBBIconButtonSmall(icon: SBBIcons.cross_small, onPressed: context.router.pop),
          ],
        ),
      ),
    );
  }

  List<Widget> _koaNotification() {
    return [
      KoaNotification(displayAction: false),
      SizedBox(height: SBBSpacing.medium),
    ];
  }

  Widget _nextStop(BuildContext context, ChecklistDepartureProcessModel model) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: .all(.circular(SBBSpacing.medium)),
        color: ThemeUtil.getColor(context, SBBColors.night, SBBColors.nightDark),
      ),
      width: .infinity,
      height: 44.0,
      alignment: .centerLeft,
      margin: .only(bottom: SBBSpacing.medium),
      padding: .symmetric(horizontal: SBBSpacing.medium),
      child: Row(
        children: [
          SvgPicture.asset(
            AppAssets.iconHeaderStop,
            colorFilter: ColorFilter.mode(SBBColors.white, BlendMode.srcIn),
          ),
          RichText(
            text: TextSpan(
              text: 'Nächster Halt: ', // TODO: l10n
              style: SBBTextStyles.mediumLight.copyWith(color: SBBColors.white),
              children: [
                TextSpan(
                  text: model.nextStop?.name ?? context.l10n.c_unknown,
                  style: SBBTextStyles.mediumBold.copyWith(color: SBBColors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _staticDepartureProcessChecklist(BuildContext context, ChecklistDepartureProcessModel model) {
    final isCustomerOrientedDepartureActive = model is CustomerOrientedDepartureChecklist;
    return SBBContentBox(
      child: Column(
        mainAxisSize: .min,
        children: [
          SBBListItem(title: '1. Zustimmung prüfen', onPressed: _doNothing),
          SBBListItem(title: '2. Zugbeeinflussung beachten', onPressed: _doNothing),
          SBBListItem(
            title: isCustomerOrientedDepartureActive
                ? '3. KoA / Abfahrzeit beachten'
                : '3. Abfahrerlaubnis / Abfahrzeit beachten',
            onPressed: _doNothing,
          ),
          SBBListItem(title: '4. Türverriegelung kontrollieren', onPressed: _doNothing),
          SBBListItem(title: '5. Zustimmung nochmals prüfen', onPressed: _doNothing, isLastElement: true),
        ],
      ),
    );
  }

  void _doNothing() {}
}
