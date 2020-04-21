package cc.narumi.chaldea


import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val _channel = "cc.narumi.chaldea"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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
