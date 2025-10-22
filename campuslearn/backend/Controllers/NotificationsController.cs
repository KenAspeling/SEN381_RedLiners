using Microsoft.AspNetCore.Mvc;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Services;

namespace CampusLearnBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NotificationsController : ControllerBase
    {
        private readonly INotificationService _notificationService;
        private readonly IAuthService _authService;

        public NotificationsController(INotificationService notificationService, IAuthService authService)
        {
            _notificationService = notificationService;
            _authService = authService;
        }

        // Helper method to get user ID from token
        private int? GetUserIdFromToken()
        {
            var authHeader = Request.Headers["Authorization"].FirstOrDefault();
            if (authHeader == null || !authHeader.StartsWith("Bearer "))
                return null;

            var token = authHeader.Substring("Bearer ".Length).Trim();
            return _authService.GetUserIdFromToken(token);
        }

        // GET: api/notifications
        // Get all notifications for the authenticated user
        [HttpGet]
        public async Task<IActionResult> GetNotifications([FromQuery] bool unreadOnly = false)
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            var notifications = await _notificationService.GetUserNotificationsAsync(userId.Value, unreadOnly);
            return Ok(notifications);
        }

        // GET: api/notifications/count
        // Get unread notification count
        [HttpGet("count")]
        public async Task<IActionResult> GetUnreadCount()
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            var count = await _notificationService.GetUnreadCountAsync(userId.Value);
            return Ok(new { count });
        }

        // PUT: api/notifications/{id}/read
        // Mark a notification as read
        [HttpPut("{id}/read")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            var success = await _notificationService.MarkAsReadAsync(id, userId.Value);
            if (!success)
                return NotFound(new { message = "Notification not found" });

            return Ok(new { message = "Notification marked as read" });
        }

        // PUT: api/notifications/read-all
        // Mark all notifications as read
        [HttpPut("read-all")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            var count = await _notificationService.MarkAllAsReadAsync(userId.Value);
            return Ok(new { message = $"Marked {count} notifications as read", count });
        }

        // DELETE: api/notifications/{id}
        // Delete a notification
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteNotification(int id)
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            var success = await _notificationService.DeleteNotificationAsync(id, userId.Value);
            if (!success)
                return NotFound(new { message = "Notification not found" });

            return Ok(new { message = "Notification deleted" });
        }

        // DELETE: api/notifications/read
        // Delete all read notifications
        [HttpDelete("read")]
        public async Task<IActionResult> DeleteAllRead()
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            var count = await _notificationService.DeleteAllReadAsync(userId.Value);
            return Ok(new { message = $"Deleted {count} read notifications", count });
        }
    }
}
