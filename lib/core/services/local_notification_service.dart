import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../../features/todo/data/datasource/task_local_datasource.dart';
import '../../platform/widget_bridge.dart';

// local_notification_service.dart
import 'dart:math';
import 'dart:ui' show DartPluginRegistrant;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:unicon_todo/features/todo/data/datasource/task_local_datasource.dart';
import '../../platform/widget_bridge.dart';

class LocalNotificationService {
  static Future<void> init() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'todo_channel',
        channelName: 'Todo Notifications',
        channelDescription: 'Eslatmalar',
        importance: NotificationImportance.High,
      ),
    ]);

    // ❗️Top-level handler’ni beramiz (class ichidagi static emas!)
    AwesomeNotifications().setListeners(onActionReceivedMethod: awesomeNotificationsActionHandler);
  }

  static Future<void> showTaskNotification({required int taskId, required String title}) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: taskId,
        // istasangiz Random() ham mumkin
        channelKey: 'todo_channel',
        title: 'Bajardingizmi?',
        body: title,
        payload: {'taskId': '$taskId'},
        autoDismissible: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DONE',
          label: 'O‘qilgan deb belgilash',
          actionType: ActionType.SilentAction, // app ochilmaydi
        ),
      ],
    );
  }
}

// local_notification_service.dart (faqat handlerning oxirini ko‘rsatyapman)
@pragma('vm:entry-point')
Future<void> awesomeNotificationsActionHandler(ReceivedAction action) async {
  DartPluginRegistrant.ensureInitialized();
  if (action.buttonKeyPressed != 'DONE') return;

  final id = int.tryParse(action.payload?['taskId'] ?? '');
  if (id == null) return;

  final ds = TaskLocalDataSourceImpl();
  await ds.toggleTask(id, true);

  // widget sonlarini hisoblash
  final items = await ds.getTasks();
  final all = items.length;
  final done = items.where((e) => e.done == true).length;
  final undone = all - done;

  // 1) Bevosita yangilashga urinish
  // try {
  //   await WidgetBridge.updateWidgetCounts(all: all, done: done, undone: undone);
  // } catch (_) {
  //   // 2) Agar background izolatda bo‘lsa — service orqali UI izolatga signal yuboramiz
  // }

  // ✅ Har holda signal yuborib qo‘yamiz (kafolat uchun)
  try {
    FlutterBackgroundService().invoke('widget_refresh', {'all': all, 'done': done, 'undone': undone});
  } catch (_) {
    await _safeEmitWidgetRefresh(all: all, done: done, undone: undone);
  }

  // (ixtiyoriy) tasdiq notifi
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      channelKey: 'todo_channel',
      title: '✅ Vazifa bajarildi',
      body: 'Task muvaffaqiyatli belgilandi',
      autoDismissible: true,
    ),
  );
}

Future<void> _safeEmitWidgetRefresh({required int all, required int done, required int undone}) async {
  try {
    final service = FlutterBackgroundService();
    final running = await service.isRunning();
    if (!running) {
      // Service ishlamasa – ishga tushiramiz
      await service.startService();
      // Launch paytida izolat ko‘tarilib olishi uchun ozgina kutamiz
      await Future.delayed(const Duration(milliseconds: 400));
    }
    service.invoke('widget_refresh', {'all': all, 'done': done, 'undone': undone});
  } catch (e) {
    // 2-urinish (qisqa retry)
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      FlutterBackgroundService().invoke('widget_refresh', {'all': all, 'done': done, 'undone': undone});
    } catch (_) {}
  }
}
