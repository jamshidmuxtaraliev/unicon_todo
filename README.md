Todo (TDD) + Home Widget + Native Background Reminders

A production-ready Flutter Todo app built with TDD, featuring an Android home widget (shows all / done / undone counts) and a native background reminder system that alerts you about tasks that have been pending for 1+ hour, even when the app is killed.

✨ Features

✅ TDD-first: domain, use-cases, and BLoC tested

🏠 Home Widget (Android): displays All / Done / Undone counts

🔔 Reminders: native AlarmManager + BroadcastReceivers (+ optional Foreground Service)

📴 Works when app is killed (not just in foreground)

🧩 Clean, modular structure (Domain / Data / Presentation / Android Native)

🧠 Optional: real-time UI refresh when a notification action marks a task as done (while app is open)

🧱 Architecture
lib/
  features/todo/
    domain/
      entities/TaskEntity.dart
      repositories/TaskRepository.dart
      usecases/...
    data/
      datasources/task_local_data_source.dart   // sqflite
      repositories/TaskRepositoryImpl.dart
    presentation/
      logic/task_bloc/...
      screens/...
      widgets/...

android/app/src/main/kotlin/com/example/unicon_todo/
  AlarmScheduler.kt            // schedules exact alarms
  DBCheckReceiver.kt           // checks DB, shows reminders, re-schedules
  MarkDoneReceiver.kt          // handles "Done" action, updates DB + widget
  Notifications.kt             // builds & shows notifications
  PersistentService.kt         // optional Foreground Service (keeps process alive)
  TaskWidgetProvider.kt        // AppWidgetProvider (home widget)
  MainActivity.kt              // permissions + optional Flutter channels

android/app/src/main/res/
  layout/task_widget.xml
  xml/task_widget_info.xml

🗄️ Database

SQLite via sqflite

Table: tasks

id (PK)

title (TEXT)

description (TEXT)

done (INTEGER 0/1)

created_at (INTEGER ms)

last_notified_at (INTEGER ms, nullable)

DB file path (Android): …/app_flutter/todo_clean.db

Native side opens the same file directly using this path.

🏠 Home Widget (Android)

SharedPreferences key: todo_prefs

all, done, undone (integers)

TaskWidgetProvider reads those keys and updates the UI.

Native receivers write fresh counts and call TaskWidgetProvider.updateAllWidgets(context).

⏰ Background Reminder System (Native)
Why native?

To be reliable even when the app is killed, the reminder pipeline is implemented in Kotlin without relying on Flutter isolates or MethodChannels.

Flow

DBCheckReceiver

Triggered by AlarmManager.

Finds tasks where:

done = 0

created_at <= now - 1h

last_notified_at IS NULL OR last_notified_at <= now - 1h

Shows a notification for each due task and sets last_notified_at = now.

Computes the next nearest due time and schedules the next exact alarm.

MarkDoneReceiver

Handles the notification action (“Bajarildi/Done”).

Sets done = 1 for the task, recomputes counts, updates widget, dismisses the notification.

Broadcasts ACTION_TASK_CHANGED (optional) so the Flutter UI can reload when the app is open.

AlarmScheduler

Schedules exact alarms using setExactAndAllowWhileIdle.

Falls back to inexact if exact permission isn’t granted.

PersistentService (optional but recommended)

Foreground service with a low-priority sticky notification.

Helps keep the process alive on aggressive OEMs (still can’t bypass Force Stop).

Boot handling

(Optional) BootReceiver can kick off the chain after device reboot.

⚠️ Android policy: If the user Force Stops the app (Settings → Apps → Force stop), the OS blocks all receivers/alarms until the app is launched again.

🔐 Android Permissions & Setup
AndroidManifest.xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<!-- Optional but recommended for exact alarms on Android 12+ -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>

Request runtime permissions (in MainActivity.kt)

POST_NOTIFICATIONS (API 33+)

Exact alarms (API 31+):

val am = getSystemService(AlarmManager::class.java)
if (!am.canScheduleExactAlarms()) {
    startActivity(Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM))
}


(Optional) Ask user to ignore battery optimizations on aggressive OEMs.

🚀 Running

Ensure Flutter environment is set up.

flutter pub get

Run on Android device/emulator.

The first launch:

Requests notification (and possibly exact alarm) permissions.

Starts the optional PersistentService.

Triggers an initial DB check broadcast.
