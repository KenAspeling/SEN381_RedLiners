using Microsoft.EntityFrameworkCore;
using CampusLearnBackend.Data;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Models;

namespace CampusLearnBackend.Services
{
    public class MessageService : IMessageService
    {
        private readonly CampusLearnContext _context;

        public MessageService(CampusLearnContext context)
        {
            _context = context;
        }

        public async Task<List<ConversationDto>> GetConversationsAsync(int userId)
        {
            // Get all users that the current user has messaged with
            var conversationUserIds = await _context.DirectMessages
                .Where(m => m.SenderId == userId || m.RecipientId == userId)
                .Select(m => m.SenderId == userId ? m.RecipientId : m.SenderId)
                .Distinct()
                .ToListAsync();

            var conversations = new List<ConversationDto>();

            foreach (var otherUserId in conversationUserIds)
            {
                if (!otherUserId.HasValue) continue;

                var otherUser = await _context.Users
                    .FirstOrDefaultAsync(u => u.UserId == otherUserId.Value);

                if (otherUser == null) continue;

                // Get last message between these users
                var lastMessage = await _context.DirectMessages
                    .Include(m => m.Sender)
                    .Include(m => m.Recipient)
                    .Where(m => (m.SenderId == userId && m.RecipientId == otherUserId) ||
                               (m.SenderId == otherUserId && m.RecipientId == userId))
                    .OrderByDescending(m => m.TimeCreated)
                    .FirstOrDefaultAsync();

                // Count unread messages from this user
                var unreadCount = await _context.DirectMessages
                    .CountAsync(m => m.SenderId == otherUserId &&
                                    m.RecipientId == userId &&
                                    !m.Read);

                conversations.Add(new ConversationDto
                {
                    UserId = otherUser.UserId,
                    UserName = $"{otherUser.Name} {otherUser.Surname}",
                    UserEmail = otherUser.Email,
                    LastMessage = lastMessage != null ? MapToMessageDto(lastMessage) : null,
                    UnreadCount = unreadCount
                });
            }

            // Sort by last message time (most recent first)
            return conversations
                .OrderByDescending(c => c.LastMessage?.TimeCreated ?? DateTime.MinValue)
                .ToList();
        }

        public async Task<List<MessageDto>> GetMessagesWithUserAsync(int userId, int otherUserId)
        {
            var messages = await _context.DirectMessages
                .Include(m => m.Sender)
                .Include(m => m.Recipient)
                .Where(m => (m.SenderId == userId && m.RecipientId == otherUserId) ||
                           (m.SenderId == otherUserId && m.RecipientId == userId))
                .OrderBy(m => m.TimeCreated)
                .ToListAsync();

            // Mark messages from the other user as read
            var unreadMessages = messages.Where(m => m.SenderId == otherUserId && !m.Read).ToList();
            foreach (var message in unreadMessages)
            {
                message.Read = true;
            }

            if (unreadMessages.Any())
            {
                await _context.SaveChangesAsync();
            }

            return messages.Select(MapToMessageDto).ToList();
        }

        public async Task<MessageDto?> SendMessageAsync(SendMessageDto sendMessageDto, int senderId)
        {
            // Verify recipient exists
            var recipient = await _context.Users.FindAsync(sendMessageDto.RecipientId);
            if (recipient == null)
                return null;

            var message = new DirectMessage
            {
                SenderId = senderId,
                RecipientId = sendMessageDto.RecipientId,
                Content = sendMessageDto.Content,
                MaterialId = sendMessageDto.MaterialId,
                TimeCreated = DateTime.UtcNow,
                Read = false
            };

            _context.DirectMessages.Add(message);
            await _context.SaveChangesAsync();

            // Reload with navigation properties
            await _context.Entry(message)
                .Reference(m => m.Sender)
                .LoadAsync();
            await _context.Entry(message)
                .Reference(m => m.Recipient)
                .LoadAsync();

            return MapToMessageDto(message);
        }

        public async Task<bool> MarkAsReadAsync(int messageId, int userId)
        {
            var message = await _context.DirectMessages
                .FirstOrDefaultAsync(m => m.MessageId == messageId && m.RecipientId == userId);

            if (message == null)
                return false;

            message.Read = true;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<int> GetUnreadCountAsync(int userId)
        {
            return await _context.DirectMessages
                .CountAsync(m => m.RecipientId == userId && !m.Read);
        }

        private MessageDto MapToMessageDto(DirectMessage message)
        {
            return new MessageDto
            {
                MessageId = message.MessageId,
                SenderId = message.SenderId ?? 0,
                SenderName = message.Sender != null
                    ? $"{message.Sender.Name} {message.Sender.Surname}"
                    : "Unknown",
                SenderEmail = message.Sender?.Email ?? "unknown@campuslearn.com",
                RecipientId = message.RecipientId ?? 0,
                RecipientName = message.Recipient != null
                    ? $"{message.Recipient.Name} {message.Recipient.Surname}"
                    : "Unknown",
                RecipientEmail = message.Recipient?.Email ?? "unknown@campuslearn.com",
                Content = message.Content,
                TimeCreated = message.TimeCreated,
                Read = message.Read,
                MaterialId = message.MaterialId
            };
        }
    }
}
