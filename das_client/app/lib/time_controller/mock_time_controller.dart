import 'package:app/time_controller/time_controller.dart';

class MockTimeController extends TimeController {
  final int _stale = 1;
  final int _disappear = 3;
  final int _idleModal = 5;
  final int _idleAuto = 5;

  MockTimeController();

  @override
  int get punctualityStaleSeconds => _stale;

  @override
  int get punctualityDisappearSeconds => _disappear;

  @override
  int get idleTimeDASModalSheet => _idleModal;

  @override
  int get idleTimeAutoScroll => _idleAuto;
}
