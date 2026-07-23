import 'package:app/di/di.dart';
import 'package:warnapp/component.dart';

/// Shadows [WarnappRepository] with one backed by [MockMotionDataService].
///
/// The real [DeviceMotionDataService] triggers a location permission popup that Flutter's
/// integration_test plugin cannot dismiss.
class E2EWarnappOverrideScope extends DIScope {
  @override
  String get scopeName => 'E2EWarnappOverrideScope';

  @override
  Future<void> push() async {
    getIt.pushNewScope(
      scopeName: scopeName,
      init: (getIt) => getIt.registerSingleton<WarnappRepository>(
        WarnappComponent.createWarnappRepository(
          motionDataService: WarnappComponent.createMockMotionDataService(
            samplingPeriod: const Duration(milliseconds: 2),
          ),
        ),
      ),
    );
  }
}
