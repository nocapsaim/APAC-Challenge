import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart'; // Import the notification service

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize the plugin
  Future<void> initialize() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Function to show a local notification
  Future<void> showLocalNotification(String title, String body) async {
    var android = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description', // ✅ Fixed here
      importance: Importance.high,
      priority: Priority.high,
    );
    var platform = NotificationDetails(android: android);

    await flutterLocalNotificationsPlugin.show(0, title, body, platform);
  }
}
