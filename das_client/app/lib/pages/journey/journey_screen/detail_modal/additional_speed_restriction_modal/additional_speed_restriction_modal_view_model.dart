import 'package:app/pages/journey/journey_screen/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_builder.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class AdditionalSpeedRestrictionModalViewModel {
  final _rxAdditionalSpeedRestrictionData = BehaviorSubject<AdditionalSpeedRestrictionData>();

  Stream<List<AdditionalSpeedRestriction>> get additionalSpeedRestrictions =>
      _rxAdditionalSpeedRestrictionData.map((data) => data.restrictions).distinct();

  void open(BuildContext context, AdditionalSpeedRestrictionData data) {
    _rxAdditionalSpeedRestrictionData.add(data);

    final viewModel = context.read<DetailModalViewModel>();
    viewModel.open(AdditionalSpeedRestrictionModalBuilder(), maximize: false, contentKey: data);
  }

  void close(BuildContext context) => context.read<DetailModalViewModel>().close();

  void dispose() {
    _rxAdditionalSpeedRestrictionData.close();
  }
}
