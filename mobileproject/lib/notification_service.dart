import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {

  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future init() async {

    tz.initializeTimeZones();

    // ใช้เวลาไทย
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: android);

    await notificationsPlugin.initialize(settings);
  }

  static Future scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        "schedule_channel",
        "Schedule Notification",
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,

      // ใช้ timezone ไทย
      tz.TZDateTime.from(time, tz.local),

      details,

      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}