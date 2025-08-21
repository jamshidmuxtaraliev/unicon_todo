import 'package:flutter/services.dart';

class WidgetBridge {
  static const _channel = MethodChannel('todo/widget');

  /// Widgetga sonlarni yuborish
  static Future<void> updateWidgetCounts({
    required int done,
    required int undone,
  }) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'done': done,
        'undone': undone,
      });
    } catch (e) {
      // native bo'lmasa yoki xatolik — jim o'tamiz
      print(e);
    }
  }
}
