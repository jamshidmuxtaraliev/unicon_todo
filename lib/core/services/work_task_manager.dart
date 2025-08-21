import 'dart:ui';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';

import '../../features/todo/data/datasource/task_local_datasource.dart';
import 'bacground_reminder_service.dart';
import 'local_notification_service.dart';

const String kTaskCheckOverdue = 'task_check_overdue';

@pragma('vm:entry-point')
void workmanagerDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Dart registratsiya
      DartPluginRegistrant.ensureInitialized();
      await LocalNotificationService.init();

      final ds = TaskLocalDataSourceImpl();

      // Sizning DB API: 1 soatga “due” bo‘lgan va takroriy notif kerak bo‘lgan barcha tasklar:
      final due = await ds.getDueTasksForNotify(interval: kInterval);
      for (final t in due) {
        if (t.id == null || t.done == true) continue;
        await LocalNotificationService.showTaskNotification(taskId: t.id!, title: t.title);
        await ds.markNotifiedNow(t.id!);
      }

      // Maqsad: kill bo‘lganda ham 15 daq oralig‘ida uyg‘onib, kechikkan eslatmalarni chiqarish
      return Future.value(true);
    } catch (e) {
      print('Workmanager error: $e');
      return Future.value(false);
    }
  });
}
