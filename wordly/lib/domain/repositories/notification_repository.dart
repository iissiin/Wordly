abstract class NotificationRepository {
  Future<void> initialize(String userId);
  Future<void> scheduleReviewReminder();
  Future<void> cancelAllNotifications();
}
