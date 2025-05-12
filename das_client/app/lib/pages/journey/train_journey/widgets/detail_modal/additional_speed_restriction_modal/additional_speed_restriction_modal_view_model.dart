import 'package:app/pages/journey/train_journey/widgets/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class AdditionalSpeedRestrictionModalViewModel {
  final _rxAdditionalSpeedRestriction = BehaviorSubject<AdditionalSpeedRestriction>();

  // TODO: Get count
  Stream<int> count = Stream.value(1).asBroadcastStream();

  Stream<AdditionalSpeedRestriction> get additionalSpeedRestriction => _rxAdditionalSpeedRestriction.distinct();

  void open(BuildContext context, AdditionalSpeedRestriction additionalSpeedRestriction) {
    _rxAdditionalSpeedRestriction.add(additionalSpeedRestriction);

    final viewModel = context.read<DetailModalViewModel>();
    viewModel.open(AdditionalSpeedRestrictionModalBuilder(), maximize: false);
  }

  void close(BuildContext context) => context.read<DetailModalViewModel>().close();

  void dispose() {
    _rxAdditionalSpeedRestriction.close();
  }
}
