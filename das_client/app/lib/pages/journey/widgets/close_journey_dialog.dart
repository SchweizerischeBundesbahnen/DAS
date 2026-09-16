import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

Future<bool> confirmCloseJourney(BuildContext context) async {
  final isTrainInMotion = DI
      .getOrNull<JourneyPositionViewModel>()
      ?.modelValue
      .isTrainInMotion ?? false;
  if (!isTrainInMotion) return true;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => CloseJourneyDialog(),
  );
  return confirmed ?? false;
}

class CloseJourneyDialog extends StatelessWidget {
  static const cancelButtonKey = Key('closeJourneyDialogCancelButton');
  static const confirmButtonKey = Key('closeJourneyDialogConfirmButton');

  static const double _maxWidth = 430;

  const CloseJourneyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBPopup(
      style: SBBPopupStyle(
        alignment: .topRight,
        constraints: BoxConstraints(maxWidth: _maxWidth),
      ),
      titleText: context.l10n.w_close_journey_dialog_title,
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Text(context.l10n.w_close_journey_dialog_subTitle,
            style: sbbTextStyle.small),
        SizedBox(height: SBBSpacing.large),
        SBBSecondaryButton(
          key: cancelButtonKey,
          labelText: context.l10n
              .w_close_journey_dialog_cancel_button_labelText,
          onPressed: () => context.router.pop<bool>(false),
        ),
        SizedBox(height: SBBSpacing.xSmall),
        SBBPrimaryButton(
          key: confirmButtonKey,
          labelText: context.l10n
              .w_close_journey_dialog_confirm_button_labelText,
          onPressed: () => context.router.pop<bool>(true),
        ),
      ],
    );
  }
}
