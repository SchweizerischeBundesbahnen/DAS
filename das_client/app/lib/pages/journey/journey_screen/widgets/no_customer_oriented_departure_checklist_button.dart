import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/journey_overview.dart';
import 'package:app/pages/journey/journey_screen/view_model/checklist_departure_process_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/checklist_departure_process_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/departure_process_modal_sheet.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class NoCustomerOrientedDepartureChecklistButton extends StatelessWidget {
  const NoCustomerOrientedDepartureChecklistButton({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ChecklistDepartureProcessViewModel>();
    return StreamBuilder(
      stream: vm.model,
      initialData: vm.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.requireData;
        if (model is! NoCustomerOrientedDepartureChecklist) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(left: JourneyOverview.horizontalPadding, bottom: SBBSpacing.xLarge),
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: BorderSide(color: ThemeUtil.getColor(context, SBBColors.cloud, SBBColors.iron), width: 4.0),
            ),
          ),
          child: SBBTertiaryButtonLarge(
            label: context.l10n.w_no_customer_oriented_departure_checklist_button,
            onPressed: () => showDepartureProcessModalSheet(context),
          ),
        );
      },
    );
  }
}
