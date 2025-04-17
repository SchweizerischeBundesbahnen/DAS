import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_config.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:flutter/material.dart';

abstract class WidgetRowBuilder<T extends BaseData> extends DASTableRowBuilder<T> {
  WidgetRowBuilder({
    required this.metadata,
    required super.data,
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
      identifier: identifier,
    );
  }

  Widget buildRowWidget(BuildContext context);
}
