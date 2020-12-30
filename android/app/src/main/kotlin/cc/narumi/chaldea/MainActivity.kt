package cc.narumi.chaldea
import androidx.annotation.NonNull
import io.flutter.plugins.GeneratedPluginRegistrant


import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val _channel = "cc.narumi.chaldea"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
//        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, _channel).apply {
            setMethodCallHandler { methodCall, result ->
                if (methodCall.method == "sendBackground") {
                    moveTaskToBack(false)
                    result.success(true)
                }
            }
        }
    }
}
