package com.example.unicon_todo


import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

private const val FG_CHANNEL = "task_bg_runner"
private const val FG_ID = 42

class PersistentService : Service() {

    override fun onCreate() {
        super.onCreate()
        ensureChannel()
        val notif = NotificationCompat.Builder(this, FG_CHANNEL)
            .setSmallIcon(android.R.drawable.btn_radio)
            .setContentTitle("Task reminders running")
            .setContentText("Overdue tasks will be reminded")
            .setOngoing(true)
            .build()
        startForeground(FG_ID, notif)

        // 1-darhol birinchi tekshiruvni ishga tushirish
        sendBroadcast(Intent(ACTION_DB_CHECK).apply {
            setClass(this@PersistentService, DBCheckReceiver::class.java)
            `package` = packageName
        })
        // Keyingi triggerlarni odatdagidek AlarmManager belgilaydi
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Jarayon o‘lsa ham qayta ko‘tarilsin
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(FG_CHANNEL) == null) {
                val ch = NotificationChannel(
                    FG_CHANNEL, "Task Background Runner",
                    NotificationManager.IMPORTANCE_LOW
                )
                nm.createNotificationChannel(ch)
            }
        }
    }
}
