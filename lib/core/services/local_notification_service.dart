// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// import '../../main.dart';
//
// class LocalNotificationService {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   initializeNotification() async {
//     const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );
//
//     DarwinInitializationSettings initializationSettingsIOS = const DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//
//       // onDidReceiveLocalNotification: (id, title, body, payload) {
//       //   print("IOS MESSAGE: $title $body $payload");
//       //   displayNotification(
//       //       id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       //       title: title ?? "BITU",
//       //       body: "Sizga yangi xabar bor !",
//       //       playLoad: payload ?? "");
//       // },
//     );
//
//     InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (details) {
//         // handleMessage(details.payload ?? "");
//       },
//     );
//   }
//
//   displayNotification({required int id, required String title, required String body, required String playLoad}) async {
//     print("THIS MESSAGE: $title $body $playLoad");
//     AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       icon: "@mipmap/ic_launcher",
//       importance: Importance.max,
//       priority: Priority.high,
//       visibility: NotificationVisibility.public, // 👈 lock screen'da ko‘rsatadi
//       ticker: 'ticker',
//     );
//     DarwinNotificationDetails iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//     var platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics,
//     );
//     await flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: playLoad,
//     );
//   }
// }
