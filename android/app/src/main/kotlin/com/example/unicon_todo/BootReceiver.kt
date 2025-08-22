package com.example.unicon_todo


import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (Intent.ACTION_BOOT_COMPLETED != intent.action) return

        // Foreground service’ni ishga tushiramiz
        ContextCompat.startForegroundService(
            context,
            Intent(context, PersistentService::class.java)
        )

        // Zanjirni zudlik bilan ham tepkilab yuboramiz (ixtiyoriy)
        context.sendBroadcast(Intent(ACTION_DB_CHECK).apply {
            setClass(context, DBCheckReceiver::class.java)
            `package` = context.packageName
        })
    }
}
