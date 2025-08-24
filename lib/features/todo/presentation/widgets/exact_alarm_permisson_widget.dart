import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ExactAlarmBottomSheet {
  static Future<void> checkAndShow(BuildContext context) async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 31) {
        final status = await Permission.scheduleExactAlarm.status;
        if (!status.isGranted && context.mounted) {
          _show(context);
        }
      }
    }
  }

  static void _show(BuildContext context) {
    showModalBottomSheet(context: context, isDismissible: false, enableDrag: false, builder: (_) => const _ExactAlarmSheet());
  }
}

class _ExactAlarmSheet extends StatelessWidget {
  const _ExactAlarmSheet({super.key});

  Future<void> _openSettings() async {
    await openAppSettings(); // App sozlamalariga olib boradi
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Aniq signal (Exact Alarm) ruxsati talab qilinadi",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "Davom etish uchun Sozlamalardan ruxsatni yoqing. \nIlova sozlamalari oynasida 'Alarms&Remiders' bo'limini toping va ruxsatni yoqing'",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _openSettings, child: const Text("Sozlamalarga o'tish")),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
