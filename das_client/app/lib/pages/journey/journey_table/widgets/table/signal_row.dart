import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/table/cell_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sfera/component.dart';

class SignalRow extends CellRowBuilder<Signal> {
  static const Key signalLineChangeIconKey = Key('signalLineChangeIcon');

  SignalRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.journeyPosition,
    super.config,
    super.key,
  });

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Row(
        children: [
          Expanded(child: _signalFunctions(context)),
          if (data.visualIdentifier != null) Text(data.visualIdentifier!),
        ],
      ),
    );
  }

  /// Signal functions displayed as string. Type [SignalFunction.laneChange] is ignored if other functions are given as this is displayed with an icon.
  Widget _signalFunctions(BuildContext context) {
    Iterable<SignalFunction> signalFunctions = data.functions;
    if (signalFunctions.length > 1) {
      signalFunctions = signalFunctions.where((function) => function != .laneChange && function != .unknown);
    }
    final detailModalViewModel = context.read<DetailModalViewModel>();

    return StreamBuilder(
      stream: detailModalViewModel.isModalOpen,
      initialData: detailModalViewModel.isModalOpenValue,
      builder: (context, asyncSnapshot) {
        final isModalOpen = asyncSnapshot.data ?? false;

        return Text(
          signalFunctions
              .map((function) => isModalOpen ? function.localizedNameShort(context) : function.localizedName(context))
              .join('/'),
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  @override
  DASTableCell iconsCell1(BuildContext context) {
    if (data.functions.contains(SignalFunction.laneChange)) {
      return DASTableCell(
        child: SvgPicture.asset(
          key: signalLineChangeIconKey,
          AppAssets.iconSignalLaneChange,
          colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
        ),
        alignment: Alignment.center,
      );
    }
    return DASTableCell.empty();
  }
}

extension _SignalFunctionExtension on SignalFunction {
  String localizedName(BuildContext context) {
    return switch (this) {
      .entry => context.l10n.c_main_signal_function_entry,
      .block => context.l10n.c_main_signal_function_block,
      .exit => context.l10n.c_main_signal_function_exit,
      .laneChange => context.l10n.c_main_signal_function_laneChange,
      .intermediate => context.l10n.c_main_signal_function_intermediate,
      .protection => context.l10n.c_main_signal_function_protection,
      .unknown => context.l10n.c_unknown,
    };
  }

  String localizedNameShort(BuildContext context) {
    return switch (this) {
      .entry => context.l10n.c_main_signal_function_entry_short,
      .block => context.l10n.c_main_signal_function_block_short,
      .exit => context.l10n.c_main_signal_function_exit_short,
      .laneChange => context.l10n.c_main_signal_function_laneChange_short,
      .intermediate => context.l10n.c_main_signal_function_intermediate_short,
      .protection => context.l10n.c_main_signal_function_protection_short,
      .unknown => context.l10n.c_unknown,
    };
  }
}
