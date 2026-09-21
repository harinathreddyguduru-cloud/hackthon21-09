import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/weather_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static String? _lastNotificationId;

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(initSettings);
      _initialized = true;
    } catch (e) {
      print('Notification plugin init note: $e');
    }
  }

  static Future<void> triggerAlertNotification(AlertItem alert, String location) async {
    if (alert.type == 'normal') return;
    if (_lastNotificationId == alert.id) return; // avoid duplicate spam

    _lastNotificationId = alert.id;

    const androidDetails = AndroidNotificationDetails(
      'weather_alerts_channel',
      'Weather Alerts',
      channelDescription: 'High priority alerts for rain, heat and severe weather',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notificationsPlugin.show(
        alert.id.hashCode,
        '${alert.title} - WeatherGPT',
        '${alert.message} ($location)',
        notificationDetails,
      );
    } catch (e) {
      print('Trigger notification note: $e');
    }
  }
}
