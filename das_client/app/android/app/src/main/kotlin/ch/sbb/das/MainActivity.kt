package ch.sbb.das

import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "brightness_manager"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "canWriteSettings") {
                val canWrite = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    Settings.System.canWrite(context)
                } else {
                    true
                }
                result.success(canWrite)
            } else {
                result.notImplemented()
            }
        }
    }
}