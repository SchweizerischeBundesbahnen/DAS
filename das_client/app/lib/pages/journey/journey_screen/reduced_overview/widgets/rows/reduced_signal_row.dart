import 'package:app/pages/journey/journey_screen/widgets/table/signal_row.dart';
import 'package:flutter/material.dart';

class ReducedSignalRow extends SignalRow {
  ReducedSignalRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.journeyPosition,
    required super.chevronPosition,
    super.config,
    super.key,
  }) : super(showModificationOnInformationCell: true);

  @override
  Stream<bool> isModalOpenStream(BuildContext context) => Stream.value(false).asBroadcastStream();

  @override
  bool isModalOpenValue(BuildContext context) => false;
}
