import 'package:app/i18n/src/build_context_x.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/customer_oriented_departure_notification.dart';
import 'package:app/pages/journey/journey_screen/view_model/checklist_departure_process_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/customer_oriented_departure_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/checklist_departure_process_model.dart';
import 'package:app/theme/das_colors.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

Future<void> showDepartureProcessDialog(BuildContext context) {
  return showDialog<void>(
    useRootNavigator: false,
    context: context,
    builder: (context) {
      return Provider.value(
        value: context.read<ChecklistDepartureProcessViewModel>(),
        child: Provider.value(
          value: context.read<CustomerOrientedDepartureViewModel>(),
          child: DepartureProcessDialog(),
        ),
      );
    },
  );
}

class DepartureProcessDialog extends StatelessWidget {
  static const dialogKey = Key('DepartureProcessDialogKey');

  static const _maxWidth = 352.0;

  const DepartureProcessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ChecklistDepartureProcessViewModel>();
    return StreamBuilder(
      stream: vm.model,
      initialData: vm.modelValue,
      builder: (context, snap) {
        final data = snap.requireData;
        if (data is ChecklistDepartureProcessDisabled) return SizedBox.shrink();

        return SBBPopup(
          key: dialogKey,
          titleText: context.l10n.w_departure_process_dialog_title,
          style: SBBPopupStyle(constraints: BoxConstraints(maxWidth: _maxWidth)),
          body: Column(
            mainAxisSize: .min,
            children: [
              if (data is CustomerOrientedDepartureChecklist) ..._customerOrientedDepartureNotification(),
              _nextStop(context, data),
              _staticDepartureProcessChecklist(context, data),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _customerOrientedDepartureNotification() {
    return [
      CustomerOrientedDepartureNotification(displayDepartureProcessButton: false),
      SizedBox(height: SBBSpacing.medium),
    ];
  }

  Widget _nextStop(BuildContext context, ChecklistDepartureProcessModel model) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: .all(.circular(SBBSpacing.medium)),
        color: ThemeUtil.getColor(context, DASColors.nextStopBackgroundBright, DASColors.nextStopBackgroundDark),
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
              text: context.l10n.w_departure_process_next_stop,
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
      child: IgnorePointer(
        child: Column(
          mainAxisSize: .min,
          children: SBBDivider.divideItems(
            context: context,
            items: [
              SBBListItem(titleText: context.l10n.w_departure_process_checklist_item_1, onTap: () {}),
              SBBListItem(titleText: context.l10n.w_departure_process_checklist_item_2, onTap: () {}),
              SBBListItem(
                titleText: isCustomerOrientedDepartureActive
                    ? context.l10n.w_departure_process_checklist_item_3_customer_oriented_departure
                    : context.l10n.w_departure_process_checklist_item_3,
                onTap: () {},
              ),
              SBBListItem(titleText: context.l10n.w_departure_process_checklist_item_4, onTap: () {}),
              SBBListItem(titleText: context.l10n.w_departure_process_checklist_item_5, onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
