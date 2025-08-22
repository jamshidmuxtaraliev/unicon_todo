package com.example.unicon_todo


import android.annotation.SuppressLint
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

const val ACTION_TASK_CHANGED = "com.example.unicon_todo.ACTION_TASK_CHANGED"
const val ACTION_DB_CHECK = "com.example.unicon_todo.ACTION_DB_CHECK"
const val ACTION_MARK_DONE = "com.example.unicon_todo.ACTION_MARK_DONE"
const val EXTRA_TASK_ID = "task_id"

object AlarmScheduler {

    private fun pending(context: Context): PendingIntent {
        val i = Intent(context, DBCheckReceiver::class.java).apply {
            action = ACTION_DB_CHECK
            `package` = context.packageName
        }
        return PendingIntent.getBroadcast(
            context, 1000, i,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    @SuppressLint("ScheduleExactAlarm")
    fun scheduleAt(context: Context, triggerAtMillis: Long) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = pending(context)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pi)
            } catch (_: SecurityException) {
                am.set(AlarmManager.RTC_WAKEUP, triggerAtMillis, pi)
            }
        } else {
            am.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, pi)
        }
    }

    fun scheduleInMinutes(context: Context, minutes: Long) {
        scheduleAt(context, System.currentTimeMillis() + minutes * 60_000L)
    }

    fun cancel(context: Context) {
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pending(context))
    }
}
