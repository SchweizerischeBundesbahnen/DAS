import 'package:app/pages/journey/journey_screen/header/view_model/model/short_term_change_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/src/model/journey/journey.dart';

class ShortTermChangeViewModel extends JourneyAwareViewModel {
  ShortTermChangeViewModel({
    required super.journeyTableViewModel,
    required this.journeyPositionViewModel,
  });

  final JourneyPositionViewModel journeyPositionViewModel;

  final BehaviorSubject<ShortTermChangeModel> _rxSubject = BehaviorSubject.seeded(
    ShortTermChangeModel.noShortTermChanges(),
  );

  Stream<ShortTermChangeModel> get model => _rxSubject.stream.distinct();

  ShortTermChangeModel get modelValue => _rxSubject.value;

  @override
  void journeyUpdated(Journey? journey) {}

  @override
  void journeyIdentificationChanged(Journey? journey) {}
}
