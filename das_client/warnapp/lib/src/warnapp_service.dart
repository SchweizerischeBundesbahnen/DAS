import 'package:warnapp/src/warnapp_listener.dart';

abstract class WarnappService {
  WarnappService._();

  bool get isEnabled;

  void enable();

  void disable();

  void addListener(WarnappListener listener);

  void removeListener(WarnappListener listener);
}
