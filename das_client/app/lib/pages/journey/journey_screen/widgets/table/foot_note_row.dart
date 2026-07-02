import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/foot_note_accordion.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class FootNoteRow<T extends BaseFootNote> extends WidgetRowBuilder<T> {
  FootNoteRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required this.isExpanded,
    required this.addTopMargin,
    super.config,
    super.identifier,
    this.leftPadding = 0,
  }) : super(
         stickyLevel: data.stickyLevel,
         height: FootNoteAccordion.calculateHeight(
           data: data,
           isExpanded: isExpanded,
           addTopMargin: addTopMargin,
           leftPadding: leftPadding,
         ),
       );

  final bool addTopMargin;
  final bool isExpanded;

  /// used to align content with information cell
  final double leftPadding;

  @override
  Widget buildRowWidget(BuildContext context) {
    final brakeLoadSlipVM = context.read<BrakeLoadSlipViewModel>();
    return StreamBuilder(
      stream: brakeLoadSlipVM.formationRun,
      builder: (context, asyncSnapshot) {
        final hasSIMFormation = asyncSnapshot.data?.formationRun.simTrain ?? false;
        return Container(
          color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
          child: FootNoteAccordion(
            data: data,
            title: data.title(context, metadata),
            addTopMargin: addTopMargin,
            isExpanded: isExpanded,
            leftPadding: leftPadding,
            highlightBorder: data.footNote.isSIM && hasSIMFormation,
          ),
        );
      },
    );
  }
}

extension FootNoteExtension on BaseFootNote {
  StickyLevel get stickyLevel => switch (this) {
    LineFootNote _ => .second,
    _ => .none,
  };

  String title(BuildContext context, Metadata metadata) => switch (this) {
    final LineFootNote lineFootNote => _resolveTitle(context, lineFootNote, metadata),
    _ => _defaultTitle(context),
  };

  String _resolveTitle(BuildContext context, LineFootNote lineFootNote, Metadata metadata) {
    final identifier = lineFootNote.footNote.identifier;
    if (identifier != null && metadata.lineFootNoteLocations[identifier] != null) {
      final servicePointNames = metadata.lineFootNoteLocations[identifier]!;
      return '${context.l10n.c_radn} ${servicePointNames.first} - ${servicePointNames.last}';
    } else {
      return _defaultTitle(context);
    }
  }

  String _defaultTitle(BuildContext context) {
    if (footNote.isSIM) return context.l10n.c_radn_sim;

    return switch (footNote.type) {
      .trackSpeed => '${context.l10n.c_radn} ${context.l10n.c_radn_type_track_speed}',
      .decisiveGradientUp => '${context.l10n.c_radn} ${context.l10n.c_radn_type_decisive_gradient_up}',
      .decisiveGradientDown => '${context.l10n.c_radn} ${context.l10n.c_radn_type_decisive_gradient_down}',
      .contact => '${context.l10n.c_radn} ${context.l10n.c_radn_type_contact}',
      .networkType => '${context.l10n.c_radn} ${context.l10n.c_radn_type_network_type}',
      .journey => '${context.l10n.c_radn} ${context.l10n.c_radn_type_journey}',
      null => context.l10n.c_radn,
    };
  }
}
