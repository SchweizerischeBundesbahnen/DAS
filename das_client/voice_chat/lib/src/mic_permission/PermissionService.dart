import 'package:permission_handler/permission_handler.dart';
import 'package:voice_chat/component.dart';

class PermissionService {
  Future<MicPermission> requestMicrophone() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) return MicPermission.granted;
    if (status.isPermanentlyDenied) return MicPermission.permanentlyDenied;
    return MicPermission.denied;
  }

  Future<void> openSettings() => openAppSettings();
}
