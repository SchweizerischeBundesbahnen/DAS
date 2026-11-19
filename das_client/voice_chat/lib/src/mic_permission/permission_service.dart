import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voice_chat/src/model/mic_permission.dart';

final _log = Logger('PermissionService');

class PermissionService {
  Future<MicPermission> requestMicrophone() async {
    final permission = _map(await Permission.microphone.request());
    if (permission == MicPermission.denied) {
      _log.warning('Microphone permission is denied');
    } else if (permission == MicPermission.permanentlyDenied) {
      _log.warning('Microphone permission is permanently denied; enable it in the device settings');
    }
    return permission;
  }

  Future<MicPermission> microphoneStatus() async => _map(await Permission.microphone.status);

  MicPermission _map(PermissionStatus status) {
    if (status.isGranted) return MicPermission.granted;
    if (status.isPermanentlyDenied) return MicPermission.permanentlyDenied;
    return MicPermission.denied;
  }
}
