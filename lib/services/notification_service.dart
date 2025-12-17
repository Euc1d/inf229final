import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    bool? initialized = await _notifications.initialize(settings);
    print('Notifications initialized: $initialized');

    // Запрашиваем разрешения для Android 13+
    if (initialized == true) {
      await _requestPermissions();
      _initialized = true;
    }
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      print('Android notification permission granted: $granted');
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      print('Notifications not initialized!');
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'recipe_channel',
      'Recipe Notifications',
      channelDescription: 'Notifications for recipe app',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    int notificationId = Random().nextInt(100000);
    print('Showing notification with ID: $notificationId');
    print('Title: $title, Body: $body');

    try {
      await _notifications.show(
        notificationId,
        title,
        body,
        details,
      );
      print('Notification shown successfully!');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<void> showRecipeReminder() async {
    final messages = [
      '🍳 Time to cook something delicious!',
      '👨‍🍳 What\'s for dinner today?',
      '🥗 Check out some healthy recipes!',
      '🍰 How about trying a new dessert?',
      '☕ Maybe it\'s time for a snack?',
      '🍕 Hungry? Browse some recipes!',
    ];

    final randomMessage = messages[Random().nextInt(messages.length)];

    await showInstantNotification(
      title: 'Recipe App',
      body: randomMessage,
    );
  }

  Future<void> showTimerNotification(String recipeName) async {
    await showInstantNotification(
      title: '⏰ Timer Finished!',
      body: '$recipeName is ready! 🎉',
    );
  }

  // Проверка статуса разрешений
  Future<bool> areNotificationsEnabled() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    return false;
  }
}