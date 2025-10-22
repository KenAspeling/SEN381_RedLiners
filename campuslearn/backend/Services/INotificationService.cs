using CampusLearnBackend.DTOs;

namespace CampusLearnBackend.Services
{
    public interface INotificationService
    {
        // Get all notifications for a user
        Task<List<NotificationDto>> GetUserNotificationsAsync(int userId, bool unreadOnly = false);

        // Get unread notification count
        Task<int> GetUnreadCountAsync(int userId);

        // Create a new notification
        Task<NotificationDto?> CreateNotificationAsync(CreateNotificationDto notificationDto);

        // Create multiple notifications (for subscription notifications)
        Task<int> CreateBulkNotificationsAsync(List<CreateNotificationDto> notifications);

        // Mark notification as read
        Task<bool> MarkAsReadAsync(int notificationId, int userId);

        // Mark all notifications as read for a user
        Task<int> MarkAllAsReadAsync(int userId);

        // Delete a notification
        Task<bool> DeleteNotificationAsync(int notificationId, int userId);

        // Delete all read notifications for a user
        Task<int> DeleteAllReadAsync(int userId);
    }
}
