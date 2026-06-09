import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance =
      NotificationService();

  final FlutterLocalNotificationsPlugin
      notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
  const android =
      AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  const settings =
      InitializationSettings(
    android: android,
  );

  await notifications.initialize(
    settings,
  );

  await notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails =
        AndroidNotificationDetails(
      'hunter_channel',
      'Hunter Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details =
        NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      DateTime.now()
          .millisecondsSinceEpoch ~/
          1000,
      title,
      body,
      details,
    );
  }
}