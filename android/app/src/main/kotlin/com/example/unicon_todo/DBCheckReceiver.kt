package com.example.unicon_todo


import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.util.Log

class DBCheckReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_DB_CHECK) return

        val dbPath = "${context.applicationInfo.dataDir}/app_flutter/todo_clean.db"
        val now = System.currentTimeMillis()

        // TEST uchun 1 daqiqa. Prod: 60L * 60L * 1000L
        val hourMs = 60_000L*10

        try {
            val db = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READWRITE)

            // 1) due tasklar: done=0 && created_at <= now-1h && (last_notified NULL yoki <= now-1h)
            val cutoff = now - hourMs
            val qDue = """
                SELECT id, title FROM tasks
                WHERE done=0
                  AND created_at <= ?
                  AND (last_notified_at IS NULL OR last_notified_at <= ?)
            """.trimIndent()
            val c = db.rawQuery(qDue, arrayOf(cutoff.toString(), cutoff.toString()))
            while (c.moveToNext()) {
                val id = c.getInt(0)
                val title = c.getString(1) ?: "Vazifa"
                showDueTaskNotification(context, id, title)
                db.execSQL("UPDATE tasks SET last_notified_at=? WHERE id=?", arrayOf(now, id))
            }
            c.close()

            // 2) keyingi eng yaqin trigger: MIN(COALESCE(last_notified_at, created_at) + 1h) for done=0
            val qNext = """
                SELECT MIN(COALESCE(last_notified_at, created_at) + ?)
                FROM tasks WHERE done=0
            """.trimIndent()
            val c2 = db.rawQuery(qNext, arrayOf(hourMs.toString()))
            var next: Long? = null
            if (c2.moveToFirst() && !c2.isNull(0)) next = c2.getLong(0)
            c2.close()
            db.close()

            // 3) alarm qo‘yish
            if (next != null && next > now) {
                AlarmScheduler.scheduleAt(context, next)
            } else {
                // fallback: 15 daqiqadan keyin tekshir
                AlarmScheduler.scheduleInMinutes(context, 15)
            }
        } catch (t: Throwable) {
            Log.e("DBCheckReceiver", "error: ${t.message}", t)
            AlarmScheduler.scheduleInMinutes(context, 15)
        }
    }
}
