import 'package:app/pages/journey/journey_table/widgets/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_builder.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class AdditionalSpeedRestrictionModalViewModel {
  final _rxAdditionalSpeedRestrictions = BehaviorSubject<List<AdditionalSpeedRestriction>>();

  Stream<List<AdditionalSpeedRestriction>> get additionalSpeedRestrictions => _rxAdditionalSpeedRestrictions.distinct();

  void open(BuildContext context, List<AdditionalSpeedRestriction> restrictions) {
    _rxAdditionalSpeedRestrictions.add(restrictions);

    final viewModel = context.read<DetailModalViewModel>();
    viewModel.open(AdditionalSpeedRestrictionModalBuilder(), maximize: false);
  }

  void close(BuildContext context) => context.read<DetailModalViewModel>().close();

  void dispose() {
    _rxAdditionalSpeedRestrictions.close();
  }
}
