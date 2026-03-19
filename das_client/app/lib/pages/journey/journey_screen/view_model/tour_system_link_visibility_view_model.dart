import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_advancement_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('TourSystemLinkVisibilityViewModel');

class TourSystemLinkVisibilityViewModel extends JourneyAwareViewModel {
  TourSystemLinkVisibilityViewModel({
    required JourneyTableAdvancementViewModel journeyTableAdvancementViewModel,
    required JourneyPositionViewModel journeyPositionViewModel,
    super.journeyViewModel,
  }) : _journeyTableAdvancementViewModel = journeyTableAdvancementViewModel,
       _journeyPositionViewModel = journeyPositionViewModel {
    _initSubscription();
  }

  final JourneyTableAdvancementViewModel _journeyTableAdvancementViewModel;
  final JourneyPositionViewModel _journeyPositionViewModel;

  final _rxModel = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get model => _rxModel.distinct();

  bool get modelValue => _rxModel.value;

  StreamSubscription? _subscription;
  Timer? _departureTimer;

  void _initSubscription() {
    _subscription =
        CombineLatestStream.combine3(
          journeyViewModel.journey,
          _journeyTableAdvancementViewModel.model,
          _journeyPositionViewModel.model,
          (a, b, c) => (a, b, c),
        ).listen((data) async {
          final journey = data.$1;
          final advancement = data.$2;
          final position = data.$3;

          _departureTimer?.cancel();

          if (journey == null) {
            _emit(false);
            return;
          }

          if (advancement is Paused) {
            _emit(true);
            return;
          }

          final servicePoints = journey.data.whereType<ServicePoint>();
          final currentPosition = position.currentPosition;
          if (servicePoints.isEmpty || currentPosition == null) {
            _emit(false);
            return;
          }

          if (servicePoints.last.order <= currentPosition.order) {
            _emit(true);
            return;
          }

          final firstServicePoint = servicePoints.first;
          if (firstServicePoint.order >= currentPosition.order) {
            final departureTime = firstServicePoint.arrivalDepartureTime?.plannedDepartureTime;
            if (departureTime != null) {
              final now = DateTime.now();
              if (now.isBefore(departureTime)) {
                _emit(true);
                final diff = departureTime.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
                _log.fine(
                  'Scheduling tour system link visibility change to false in ${diff / 1000}s at departure time: $departureTime',
                );
                _departureTimer = Timer(Duration(milliseconds: diff), () {
                  _emit(false);
                });
                return;
              }
            }
          }

          _emit(false);
        });
  }

  void _emit(bool value) {
    if (_rxModel.isClosed) return;

    if (value != _rxModel.value) {
      _log.info('Tour system link visibility changed to: $value');
      _rxModel.add(value);
    }
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {}

  @override
  void dispose() {
    super.dispose();
    _rxModel.close();
    _subscription?.cancel();
  }
}
