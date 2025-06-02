import 'package:warnapp/src/warnapp_service.dart';
import 'package:warnapp/src/warnapp_service_impl.dart';

export 'package:warnapp/src/warnapp_service.dart';

class WarnappComponent {
  const WarnappComponent._();

  static WarnappService createWarnappService() {
    return WarnappServiceImpl();
  }
}
