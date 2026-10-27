package ch.sbb.das

import android.content.Context
import android.os.Build
import android.provider.Settings
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val BRIGHTNESS_MANAGER_CHANNEL = "brightness_manager"
    private val CONNECTIVITY_MANAGER_CHANNEL = "connectivity_manager"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BRIGHTNESS_MANAGER_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "canWriteSettings") {
                val canWrite = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    Settings.System.canWrite(applicationContext)
                } else {
                    true
                }
                result.success(canWrite)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CONNECTIVITY_MANAGER_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "isNetworkRoaming") {
                result.success(isNetworkRoaming())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isNetworkRoaming(): Boolean {
        val telephonyManager =
            getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager ?: return false

        return try {
            telephonyManager.isNetworkRoaming
        } catch (_: SecurityException) {
            false
        }
    }
}