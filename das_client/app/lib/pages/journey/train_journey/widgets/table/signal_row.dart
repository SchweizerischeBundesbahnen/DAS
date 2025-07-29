import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
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
      signalFunctions = signalFunctions.where(
        (function) => function != SignalFunction.laneChange && function != SignalFunction.unknown,
      );
    }
    return StreamBuilder(
      stream: context.read<DetailModalViewModel>().isModalOpen,
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

// extensions

extension _SignalFunctionExtension on SignalFunction {
  String localizedName(BuildContext context) {
    return switch (this) {
      SignalFunction.entry => context.l10n.c_main_signal_function_entry,
      SignalFunction.block => context.l10n.c_main_signal_function_block,
      SignalFunction.exit => context.l10n.c_main_signal_function_exit,
      SignalFunction.laneChange => context.l10n.c_main_signal_function_laneChange,
      SignalFunction.intermediate => context.l10n.c_main_signal_function_intermediate,
      SignalFunction.protection => context.l10n.c_main_signal_function_protection,
      SignalFunction.unknown => context.l10n.c_unknown,
    };
  }

  String localizedNameShort(BuildContext context) {
    return switch (this) {
      SignalFunction.entry => context.l10n.c_main_signal_function_entry_short,
      SignalFunction.block => context.l10n.c_main_signal_function_block_short,
      SignalFunction.exit => context.l10n.c_main_signal_function_exit_short,
      SignalFunction.laneChange => context.l10n.c_main_signal_function_laneChange_short,
      SignalFunction.intermediate => context.l10n.c_main_signal_function_intermediate_short,
      SignalFunction.protection => context.l10n.c_main_signal_function_protection_short,
      SignalFunction.unknown => context.l10n.c_unknown,
    };
  }
}
