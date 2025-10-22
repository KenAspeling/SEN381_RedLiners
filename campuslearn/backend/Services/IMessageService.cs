using CampusLearnBackend.DTOs;

namespace CampusLearnBackend.Services
{
    public interface IMessageService
    {
        Task<List<ConversationDto>> GetConversationsAsync(int userId);
        Task<List<MessageDto>> GetMessagesWithUserAsync(int userId, int otherUserId);
        Task<MessageDto?> SendMessageAsync(SendMessageDto sendMessageDto, int senderId);
        Task<bool> MarkAsReadAsync(int messageId, int userId);
        Task<int> GetUnreadCountAsync(int userId);
    }
}
