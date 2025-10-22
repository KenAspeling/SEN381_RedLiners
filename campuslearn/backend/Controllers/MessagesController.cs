using Microsoft.AspNetCore.Mvc;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Services;

namespace CampusLearnBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MessagesController : ControllerBase
    {
        private readonly IMessageService _messageService;
        private readonly IAuthService _authService;

        public MessagesController(IMessageService messageService, IAuthService authService)
        {
            _messageService = messageService;
            _authService = authService;
        }

        /// <summary>
        /// Get all conversations for the current user
        /// </summary>
        [HttpGet("conversations")]
        public async Task<IActionResult> GetConversations()
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var conversations = await _messageService.GetConversationsAsync(userId.Value);
            return Ok(conversations);
        }

        /// <summary>
        /// Get all messages with a specific user
        /// </summary>
        [HttpGet("user/{otherUserId}")]
        public async Task<IActionResult> GetMessagesWithUser(int otherUserId)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var messages = await _messageService.GetMessagesWithUserAsync(userId.Value, otherUserId);
            return Ok(messages);
        }

        /// <summary>
        /// Send a new message
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> SendMessage([FromBody] SendMessageDto sendMessageDto)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (string.IsNullOrWhiteSpace(sendMessageDto.Content))
                return BadRequest(new { message = "Message content cannot be empty" });

            var message = await _messageService.SendMessageAsync(sendMessageDto, userId.Value);

            if (message == null)
                return BadRequest(new { message = "Recipient not found" });

            return CreatedAtAction(nameof(GetMessagesWithUser), new { otherUserId = message.RecipientId }, message);
        }

        /// <summary>
        /// Mark a message as read
        /// </summary>
        [HttpPut("{messageId}/read")]
        public async Task<IActionResult> MarkAsRead(int messageId)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var success = await _messageService.MarkAsReadAsync(messageId, userId.Value);

            if (!success)
                return NotFound(new { message = "Message not found or you are not the recipient" });

            return NoContent();
        }

        /// <summary>
        /// Get unread message count
        /// </summary>
        [HttpGet("unread/count")]
        public async Task<IActionResult> GetUnreadCount()
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var count = await _messageService.GetUnreadCountAsync(userId.Value);
            return Ok(new { count });
        }

        // Helper method to get current user ID from JWT token
        private int? GetCurrentUserId()
        {
            var authHeader = Request.Headers["Authorization"].FirstOrDefault();
            if (authHeader == null || !authHeader.StartsWith("Bearer "))
                return null;

            var token = authHeader.Substring("Bearer ".Length).Trim();
            return _authService.GetUserIdFromToken(token);
        }
    }
}
