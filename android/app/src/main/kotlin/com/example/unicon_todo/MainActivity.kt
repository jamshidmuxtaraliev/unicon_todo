package com.example.unicon_todo

import android.app.AlarmManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.KeyData.CHANNEL
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {

    private val CHANNEL = "todo/widget"
    private val EVENTS_CHANNEL = "todo/events"
    private var eventsChannel: MethodChannel? = null

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//            val am = getSystemService(AlarmManager::class.java)
//            if (!am.canScheduleExactAlarms()) {
//                // Foydalanuvchi uchun “Alarms & reminders” oynasini ochamiz
//                startActivity(Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM))
//            }
//        }

        // Ilk ishga tushirish: DB tekshiruvini darhol yoqib yuboramiz
        sendBroadcast(Intent(ACTION_DB_CHECK).apply {
            setClass(this@MainActivity, DBCheckReceiver::class.java)
            `package` = packageName
        })

        ContextCompat.startForegroundService(
            this,
            Intent(this, PersistentService::class.java)
        )

        val filter = IntentFilter(ACTION_TASK_CHANGED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(taskChangedReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            registerReceiver(taskChangedReceiver, filter, RECEIVER_NOT_EXPORTED)
        }


    }


    override fun onDestroy() {
        try { unregisterReceiver(taskChangedReceiver) } catch (_: Exception) {}
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        eventsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTS_CHANNEL)

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


    private val taskChangedReceiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context, intent: Intent) {
            if (intent.action == ACTION_TASK_CHANGED) {
                val id = intent.getIntExtra(EXTRA_TASK_ID, -1)
                val done = intent.getBooleanExtra("done", false)
                // 🔁 Flutterga signal (UI ochiq bo'lsa kanalda tinglanadi)
                eventsChannel?.invokeMethod(
                    "taskChanged",
                    mapOf("id" to id, "done" to done)
                )
            }
        }
    }
}
