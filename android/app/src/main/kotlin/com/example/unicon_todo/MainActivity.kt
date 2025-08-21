package com.example.unicon_todo

import android.content.Context
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.KeyData.CHANNEL
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "todo/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateWidget" -> {
                        val all = call.argument<Int>("all") ?: 0
                        val done = call.argument<Int>("done") ?: 0
                        val undone = call.argument<Int>("undone") ?: 0
                        try {
                            val prefs = getSharedPreferences("todo_prefs", Context.MODE_PRIVATE)
                            prefs.edit().putInt("all", all).putInt("done", done).putInt("undone", undone).apply()
                            TaskWidgetProvider.updateAllWidgets(this)
                            Log.d("MainActivity", "updateWidget done=$done undone=$undone")
                            result.success(null)
                        } catch (e: Exception) {
                            Log.e("MainActivity", "updateWidget error", e)
                            result.error("UPDATE_ERR", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
