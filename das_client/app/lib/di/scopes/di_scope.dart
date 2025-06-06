library;

import 'package:app/brightness/brightness_manager.dart';
import 'package:app/brightness/brightness_manager_impl.dart';
import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:app/util/device_id_info.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auth/component.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:http_x/component.dart';
import 'package:logger/component.dart';
import 'package:mqtt/component.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:sfera/component.dart';

part 'authenticated_scope.dart';
part 'das_base_scope.dart';
part 'sfera_mock_scope.dart';
part 'tms_scope.dart';

sealed class DIScope {
  String get _scopeName => '';

  final _getIt = GetIt.I;

  Future<void> push();

  Future<bool> pop() async {
    Fimber.d('Popping scope $_scopeName');
    return GetIt.I.popScopesTill(_scopeName);
  }

  Future<bool> popAbove() async {
    Fimber.d('Popping scope above $_scopeName');
    return GetIt.I.popScopesTill(_scopeName, inclusive: false);
  }
}
