using CampusLearnBackend.Data;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Models;
using Microsoft.EntityFrameworkCore;

namespace CampusLearnBackend.Services
{
    public class NotificationService : INotificationService
    {
        private readonly CampusLearnContext _context;
        private readonly IEmailService _emailService;

        public NotificationService(CampusLearnContext context, IEmailService emailService)
        {
            _context = context;
            _emailService = emailService;
        }

        public async Task<List<NotificationDto>> GetUserNotificationsAsync(int userId, bool unreadOnly = false)
        {
            try
            {
                var query = _context.Notifications
                    .Where(n => n.UserId == userId);

                if (unreadOnly)
                {
                    query = query.Where(n => !n.IsRead);
                }

                var notifications = await query
                    .OrderByDescending(n => n.TimeCreated)
                    .ToListAsync();

                return notifications.Select(n => new NotificationDto
                {
                    NotificationId = n.NotificationId,
                    UserId = n.UserId,
                    Title = n.Title,
                    Message = n.Message,
                    Type = n.Type,
                    RelatedId = n.RelatedId,
                    IsRead = n.IsRead,
                    TimeCreated = n.TimeCreated
                }).ToList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting user notifications: {ex.Message}");
                return new List<NotificationDto>();
            }
        }

        public async Task<int> GetUnreadCountAsync(int userId)
        {
            try
            {
                return await _context.Notifications
                    .Where(n => n.UserId == userId && !n.IsRead)
                    .CountAsync();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting unread count: {ex.Message}");
                return 0;
            }
        }

        public async Task<NotificationDto?> CreateNotificationAsync(CreateNotificationDto notificationDto)
        {
            try
            {
                var notification = new Notification
                {
                    UserId = notificationDto.UserId,
                    Title = notificationDto.Title,
                    Message = notificationDto.Message,
                    Type = notificationDto.Type,
                    RelatedId = notificationDto.RelatedId,
                    IsRead = false,
                    TimeCreated = DateTime.UtcNow
                };

                _context.Notifications.Add(notification);
                await _context.SaveChangesAsync();

                Console.WriteLine($"[NOTIFICATION] Created notification {notification.NotificationId} for user {notification.UserId}: {notification.Title}");

                // Fetch user data BEFORE background task to avoid DbContext threading issues
                var user = await _context.Users.FindAsync(notificationDto.UserId);

                // Send email notification in background (don't wait for it)
                _ = Task.Run(async () =>
                {
                    try
                    {
                        // User data already fetched above
                        if (user != null && !string.IsNullOrEmpty(user.Email))
                        {
                            var userName = $"{user.Name} {user.Surname}".Trim();
                            await _emailService.SendNotificationEmailAsync(
                                user.Email,
                                userName,
                                notificationDto.Type,
                                notificationDto.Title,
                                notificationDto.Message
                            );
                        }
                    }
                    catch (Exception emailEx)
                    {
                        Console.WriteLine($"[EMAIL ERROR] Failed to send email for notification {notification.NotificationId}: {emailEx.Message}");
                    }
                });

                return new NotificationDto
                {
                    NotificationId = notification.NotificationId,
                    UserId = notification.UserId,
                    Title = notification.Title,
                    Message = notification.Message,
                    Type = notification.Type,
                    RelatedId = notification.RelatedId,
                    IsRead = notification.IsRead,
                    TimeCreated = notification.TimeCreated
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error creating notification: {ex.Message}");
                return null;
            }
        }

        public async Task<int> CreateBulkNotificationsAsync(List<CreateNotificationDto> notifications)
        {
            try
            {
                var notificationEntities = notifications.Select(dto => new Notification
                {
                    UserId = dto.UserId,
                    Title = dto.Title,
                    Message = dto.Message,
                    Type = dto.Type,
                    RelatedId = dto.RelatedId,
                    IsRead = false,
                    TimeCreated = DateTime.UtcNow
                }).ToList();

                _context.Notifications.AddRange(notificationEntities);
                var count = await _context.SaveChangesAsync();

                Console.WriteLine($"[NOTIFICATION] Created {count} notifications in bulk");

                // Fetch user data BEFORE background task to avoid DbContext threading issues
                var userIds = notifications.Select(n => n.UserId).Distinct().ToList();
                var userList = await _context.Users
                    .Where(u => userIds.Contains(u.UserId))
                    .ToListAsync();
                var users = userList.ToDictionary(u => u.UserId);

                // Send bulk emails in background (don't wait for it)
                _ = Task.Run(async () =>
                {
                    try
                    {
                        // User data already fetched above

                        // Prepare email list
                        var emails = new List<(string email, string name, string subject, string body)>();

                        foreach (var notif in notifications)
                        {
                            if (users.TryGetValue(notif.UserId, out var user) && !string.IsNullOrEmpty(user.Email))
                            {
                                var userName = $"{user.Name} {user.Surname}".Trim();
                                var subject = $"Campus Learn: {notif.Title}";

                                // Use simple text body for bulk to speed up sending
                                var body = $@"
                                    <h2>{notif.Title}</h2>
                                    <p>{notif.Message}</p>
                                    <hr>
                                    <p><small>This is an automated notification from Campus Learn.</small></p>
                                ";

                                emails.Add((user.Email, userName, subject, body));
                            }
                        }

                        if (emails.Any())
                        {
                            var sentCount = await _emailService.SendBulkEmailsAsync(emails);
                            Console.WriteLine($"[EMAIL BULK] Sent {sentCount}/{emails.Count} notification emails");
                        }
                    }
                    catch (Exception emailEx)
                    {
                        Console.WriteLine($"[EMAIL BULK ERROR] Failed to send bulk emails: {emailEx.Message}");
                    }
                });

                return count;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error creating bulk notifications: {ex.Message}");
                return 0;
            }
        }

        public async Task<bool> MarkAsReadAsync(int notificationId, int userId)
        {
            try
            {
                var notification = await _context.Notifications
                    .FirstOrDefaultAsync(n => n.NotificationId == notificationId && n.UserId == userId);

                if (notification == null)
                {
                    return false;
                }

                notification.IsRead = true;
                await _context.SaveChangesAsync();

                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error marking notification as read: {ex.Message}");
                return false;
            }
        }

        public async Task<int> MarkAllAsReadAsync(int userId)
        {
            try
            {
                var unreadNotifications = await _context.Notifications
                    .Where(n => n.UserId == userId && !n.IsRead)
                    .ToListAsync();

                foreach (var notification in unreadNotifications)
                {
                    notification.IsRead = true;
                }

                return await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error marking all notifications as read: {ex.Message}");
                return 0;
            }
        }

        public async Task<bool> DeleteNotificationAsync(int notificationId, int userId)
        {
            try
            {
                var notification = await _context.Notifications
                    .FirstOrDefaultAsync(n => n.NotificationId == notificationId && n.UserId == userId);

                if (notification == null)
                {
                    return false;
                }

                _context.Notifications.Remove(notification);
                await _context.SaveChangesAsync();

                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting notification: {ex.Message}");
                return false;
            }
        }

        public async Task<int> DeleteAllReadAsync(int userId)
        {
            try
            {
                var readNotifications = await _context.Notifications
                    .Where(n => n.UserId == userId && n.IsRead)
                    .ToListAsync();

                _context.Notifications.RemoveRange(readNotifications);
                return await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting read notifications: {ex.Message}");
                return 0;
            }
        }
    }
}
