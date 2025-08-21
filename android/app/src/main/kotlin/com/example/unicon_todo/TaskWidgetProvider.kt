package com.example.unicon_todo

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.util.Log
import android.widget.RemoteViews

class TaskWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, mgr: AppWidgetManager, appWidgetIds: IntArray) {
        Log.d("TaskWidgetProvider", "onUpdate ids=${appWidgetIds.contentToString()}")
        for (id in appWidgetIds) {
            updateSingle(context, mgr, id)
        }
    }

    companion object {
        private const val PREFS = "todo_prefs"
        private const val KEY_ALL = "all"
        private const val KEY_DONE = "done"
        private const val KEY_UNDONE = "undone"

        fun updateAllWidgets(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, TaskWidgetProvider::class.java)
            val ids = mgr.getAppWidgetIds(component)
            for (id in ids) updateSingle(context, mgr, id)
        }

        private fun updateSingle(context: Context, mgr: AppWidgetManager, appWidgetId: Int) {
            try {
                val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                val all = prefs.getInt(KEY_ALL, 0)
                val done = prefs.getInt(KEY_DONE, 0)
                val undone = prefs.getInt(KEY_UNDONE, 0)

                val views = RemoteViews(context.packageName, R.layout.task_widget)
                views.setTextViewText(R.id.txt_all, all.toString())
                views.setTextViewText(R.id.txt_done, done.toString())
                views.setTextViewText(R.id.txt_undone, undone.toString())

                val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
                val pending = PendingIntent.getActivity(
                    context, 0, launch,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pending)

                mgr.updateAppWidget(appWidgetId, views)
                Log.d("TaskWidgetProvider", "updated id=$appWidgetId done=$done undone=$undone")
            } catch (e: Exception) {
                Log.e("TaskWidgetProvider", "update error id=$appWidgetId", e)
            }
        }
    }
}
