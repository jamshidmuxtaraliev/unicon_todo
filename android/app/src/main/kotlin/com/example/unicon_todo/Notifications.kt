package com.example.unicon_todo


import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

private const val CHANNEL_ID = "high_importance_channel"

private fun ensureNotifChannel(context: Context) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (nm.getNotificationChannel(CHANNEL_ID) == null) {
            val ch = NotificationChannel(
                CHANNEL_ID, "Task Reminders",
                NotificationManager.IMPORTANCE_HIGH
            )
            ch.description = "Reminders for overdue tasks"
            nm.createNotificationChannel(ch)
        }
    }
}

fun showDueTaskNotification(context: Context, taskId: Int, title: String) {
    ensureNotifChannel(context)

    val markIntent = Intent(context, MarkDoneReceiver::class.java).apply {
        action = ACTION_MARK_DONE
        putExtra(EXTRA_TASK_ID, taskId)
        `package` = context.packageName
    }
    val markPending = PendingIntent.getBroadcast(
        context, taskId, markIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    val notif = NotificationCompat.Builder(context, CHANNEL_ID)
        // Maxsus ikon kerak bo‘lmasin desangiz, tizim ikonini ishlatamiz:
        .setSmallIcon(android.R.drawable.stat_notify_more)
        .setContentTitle("Bajardingizmi?")
        .setContentText(if (title.isBlank()) "Vazifa" else title)
        .setAutoCancel(true)
        .addAction(0, "Bajarildi", markPending)
        .build()

    NotificationManagerCompat.from(context).notify(taskId, notif)
}
