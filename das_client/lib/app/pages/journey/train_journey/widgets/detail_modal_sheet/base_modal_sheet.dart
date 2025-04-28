import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/base_modal_sheet_view_model.dart';
import 'package:das_client/app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BaseModalSheet extends StatelessWidget {
  const BaseModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<BaseModalSheetViewModel>();
    return StreamBuilder(
      stream: viewModel.contentBuilder,
      builder: (context, snapshot) {
        return DasModalSheet(
          controller: viewModel.controller,
          leftMargin: sbbDefaultSpacing * 0.5,
          builder: snapshot.data ?? DASModalSheetBuilder(),
        );
      },
    );
  }
}
