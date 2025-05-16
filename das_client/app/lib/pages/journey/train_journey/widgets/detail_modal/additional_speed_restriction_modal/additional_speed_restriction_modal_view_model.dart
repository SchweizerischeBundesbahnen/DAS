import 'package:app/pages/journey/train_journey/widgets/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class AdditionalSpeedRestrictionModalViewModel {
  /// TODO: NumberOfRestrictions will make more sense when sequence or complex ASR are implemented
  final _rxNumberOfRestrictions = BehaviorSubject<int>();
  final _rxAdditionalSpeedRestriction = BehaviorSubject<AdditionalSpeedRestriction>();

  Stream<int> get numberOfRestrictions => _rxNumberOfRestrictions.distinct();

  Stream<AdditionalSpeedRestriction> get additionalSpeedRestriction => _rxAdditionalSpeedRestriction.distinct();

  void open(BuildContext context, AdditionalSpeedRestriction restriction) {
    _rxAdditionalSpeedRestriction.add(restriction);
    _rxNumberOfRestrictions.add(1);

    final viewModel = context.read<DetailModalViewModel>();
    viewModel.open(AdditionalSpeedRestrictionModalBuilder(), maximize: false);
  }

  void close(BuildContext context) => context.read<DetailModalViewModel>().close();

  void dispose() {
    _rxAdditionalSpeedRestriction.close();
    _rxNumberOfRestrictions.close();
  }
}
