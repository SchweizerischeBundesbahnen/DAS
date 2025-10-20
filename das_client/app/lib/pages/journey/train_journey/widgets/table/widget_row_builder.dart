import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_config.dart';
import 'package:app/widgets/table/das_table_row.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

abstract class WidgetRowBuilder<T extends BaseData> extends DASTableRowBuilder<T> {
  WidgetRowBuilder({
    required this.metadata,
    required super.data,
    required super.rowIndex,
    required super.height,
    super.stickyLevel,
    super.identifier,
    this.config = const TrainJourneyConfig(),
  });

  final Metadata metadata;
  final TrainJourneyConfig config;

  @override
  DASTableRow build(BuildContext context) {
    return DASTableWidgetRow(
      key: key,
      widget: buildRowWidget(context),
      height: height,
      stickyLevel: stickyLevel,
      rowIndex: rowIndex,
      identifier: identifier,
    );
  }

  Widget buildRowWidget(BuildContext context);
}
