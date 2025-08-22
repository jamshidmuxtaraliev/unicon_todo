package com.example.unicon_todo


import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import androidx.core.app.NotificationManagerCompat

class MarkDoneReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_MARK_DONE) return

        val taskId = intent.getIntExtra(EXTRA_TASK_ID, -1)
        if (taskId <= 0) return

        val dbPath = "${context.applicationInfo.dataDir}/app_flutter/todo_clean.db"
        try {
            val db = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READWRITE)

            // 1) done=1
            db.execSQL("UPDATE tasks SET done=1 WHERE id=?", arrayOf(taskId))

            // 2) countlar
            val cAll = db.rawQuery("SELECT COUNT(*) FROM tasks", null)
            cAll.moveToFirst(); val all = cAll.getInt(0); cAll.close()
            val cDone = db.rawQuery("SELECT COUNT(*) FROM tasks WHERE done=1", null)
            cDone.moveToFirst(); val done = cDone.getInt(0); cDone.close()
            db.close()
            val undone = all - done

            // 3) widget PREFS va yangilash
            val prefs = context.getSharedPreferences("todo_prefs", Context.MODE_PRIVATE)
            prefs.edit().putInt("all", all).putInt("done", done).putInt("undone", undone).apply()
            TaskWidgetProvider.updateAllWidgets(context)

            // 4) notifni yopish
            NotificationManagerCompat.from(context).cancel(taskId)

            // UI ochiq bo‘lsa Flutterga xabar
            context.sendBroadcast(Intent(ACTION_TASK_CHANGED).apply {
                `package` = context.packageName      // faqat o'z paketimizga
                putExtra(EXTRA_TASK_ID, taskId)
                putExtra("done", true)
            })

            // 5) Jadvalni qayta hisoblatish (keyingi alarm rejalashtirilsin)
            context.sendBroadcast(Intent(ACTION_DB_CHECK).apply {
                setClass(context, DBCheckReceiver::class.java)
                `package` = context.packageName
            })
        } catch (t: Throwable) {
            Log.e("MarkDoneReceiver", "failed: ${t.message}", t)
        }
    }
}
