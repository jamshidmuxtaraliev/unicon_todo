import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:unicon_todo/core/services/work_task_manager.dart';
import 'package:workmanager/workmanager.dart';

import 'package:unicon_todo/features/todo/domain/entities/task.dart';

import '../../features/todo/data/datasource/task_local_datasource.dart';
import '../../platform/widget_bridge.dart';
import 'local_notification_service.dart';

const Duration kInterval = Duration(minutes: 30);

final Map<int, Timer> _timers = {};

class TaskBackgroundService {
  /// App start/Resume’da chaqiring — servisni ko‘taradi, WorkManager fallbackni ham yoqadi.
  static Future<void> configureAndStart() async {
    // 1) WorkManager INIT (fallback)
    try {
      await Workmanager().initialize(workmanagerDispatcher, isInDebugMode: false);

      // Har 15 daqiqada uyg‘onib overdue’larni chiqarish (servis kill holatida ham)
      await Workmanager().registerPeriodicTask(
        'wm-overdue-check',
        kTaskCheckOverdue,
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(minutes: 5),
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 5),
      );
    } catch (e) {
      print('WorkManager init/register error: $e');
    }

    // 2) Local notifications init (listener shu yerda faollashadi)
    await LocalNotificationService.init();

    // 3) Flutter background service INIT
    final FlutterBackgroundService service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
        autoStartOnBoot: true,
        initialNotificationTitle: 'Unicon Todo',
        initialNotificationContent: 'Eslatmalar xizmati ishga tushdi',
        foregroundServiceNotificationId: 1100,
      ),
      iosConfiguration: IosConfiguration(autoStart: false),
    );

    // 4) Har chaqirilganda ehtiyot uchun startService()
    await service.startService();

    // 5) Darhol reschedule signalini yuboramiz
    refresh();
  }

  /// DB o‘zgarsa yoki app ochilganda timerlarni qayta hisoblash uchun
  static void refresh() {
    FlutterBackgroundService().invoke('refresh');
  }
}

/// Background entry-point
@pragma('vm:entry-point')
Future<bool> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(title: 'Task Manager', content: 'Eslatmalar xizmati ishlamoqda…');
  }

  // 0) widget_refresh listener'ini BIRINCHI bo‘lib qo‘yamiz (signal erta kelsa ham ushlasin)
  service.on('widget_refresh').listen((event) async {
    try {
      if (kDebugMode) print('[BG] widget_refresh signal: $event');

      final all = (event?['all'] as num?)?.toInt() ?? 0;
      final done = (event?['done'] as num?)?.toInt() ?? 0;
      final undone = (event?['undone'] as num?)?.toInt() ?? 0;

      await WidgetBridge.updateWidgetCounts(all: all, done: done, undone: undone);
      if (kDebugMode) print('[BG] WidgetBridge.updateWidgetCounts applied: $all/$done/$undone');
    } catch (e) {
      if (kDebugMode) print('[BG] widget_refresh apply error: $e');
    }
  });

  // 1) Notifikatsiya kanal va action-listenerlar
  await LocalNotificationService.init();

  final ds = TaskLocalDataSourceImpl();

  // 2) UI izolatdan keladigan umumiy refresh signali
  service.on('refresh').listen((_) async => _rescheduleAll(ds));

  // 3) Servis ishga tushganda bir marta hammasini qayta rejalashtiramiz
  await _rescheduleAll(ds);

  // 4) Drift/Fallback mini-tiklash: 1 daqiqada bir tekshirish
  Timer.periodic(const Duration(minutes: 1), (_) => _rescheduleAll(ds));

  return true;
}

Future<void> _rescheduleAll(TaskLocalDataSource ds) async {
  try {
    // 1) Kechikkan (due) tasklarni darhol chiqarish va +interval re-arm
    final due = await ds.getDueTasksForNotify(interval: kInterval);
    for (final t in due) {
      if (t.id == null || t.done == true) continue;

      await LocalNotificationService.showTaskNotification(taskId: t.id!, title: t.title ?? 'Vazifa');

      await ds.markNotifiedNow(t.id!);

      _timers.remove(t.id!)?.cancel();
      _timers[t.id!] = Timer(kInterval, () => _notifyOnceAndRearmById(ds, t.id!));
    }

    // 2) Pending tasklar uchun keyingi fire vaqtini hisoblash va Timer qo‘yish
    final all = await ds.getTasks();
    final now = DateTime.now();

    for (final t in all) {
      if (t.id == null) continue;

      if (t.done == true) {
        _timers.remove(t.id!)?.cancel();
        continue;
      }

      final created = t.created_at;
      final firstFire = created.add(kInterval);
      Duration remain;

      if (now.isBefore(firstFire)) {
        // Hali interval to‘lmadi
        remain = firstFire.difference(now);
      } else {
        // “grid” bo‘yicha keyingi slot
        final elapsed = now.difference(created);
        final n = (elapsed.inSeconds / kInterval.inSeconds).ceil();
        final nextAt = created.add(Duration(seconds: n * kInterval.inSeconds));
        remain = nextAt.difference(now);
        if (remain.isNegative || remain.inSeconds == 0) {
          await _notifyOnceAndRearmById(ds, t.id!);
          continue;
        }
      }

      _timers.remove(t.id!)?.cancel();
      _timers[t.id!] = Timer(remain, () => _notifyOnceAndRearmById(ds, t.id!));
    }
  } catch (e) {
    if (kDebugMode) print('_rescheduleAll error: $e');
  }
}

Future<void> _notifyOnceAndRearmById(TaskLocalDataSource ds, int id) async {
  try {
    final task = await ds.getTaskById(id);
    if (task == null || task.done == true) {
      _timers.remove(id)?.cancel();
      return;
    }

    await LocalNotificationService.showTaskNotification(taskId: id, title: task.title ?? 'Vazifa');

    await ds.markNotifiedNow(id);

    _timers.remove(id)?.cancel();
    _timers[id] = Timer(kInterval, () => _notifyOnceAndRearmById(ds, id));
  } catch (e) {
    if (kDebugMode) print('_notifyOnceAndRearmById error: $e');
  }
}
