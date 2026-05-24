import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wordly/domain/repositories/notification_repository.dart';
import '../../facade/firebase_facade.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFacade _facade;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationRepositoryImpl({required FirebaseFacade facade})
      : _facade = facade;

  @override
  Future<void> initialize(String userId) async {
    await _facade.requestNotificationPermission();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    final token = await _facade.getFCMToken();
    if (token != null) {
      await _facade.saveFCMToken(userId: userId, token: token);
    }
  }

  @override
  Future<void> scheduleReviewReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'wordly_review',
      'Review Reminders',
      channelDescription: 'Reminders to review your words',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      0,
      'Time to review',
      'You have words ready for review in Wordly',
      details,
    );
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}
