namespace CampusLearnBackend.DTOs
{
    public class MessageDto
    {
        public int MessageId { get; set; }
        public int SenderId { get; set; }
        public string SenderName { get; set; } = string.Empty;
        public string SenderEmail { get; set; } = string.Empty;
        public int RecipientId { get; set; }
        public string RecipientName { get; set; } = string.Empty;
        public string RecipientEmail { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public DateTime TimeCreated { get; set; }
        public bool Read { get; set; }
        public int? MaterialId { get; set; }
    }

    public class SendMessageDto
    {
        public int RecipientId { get; set; }
        public string Content { get; set; } = string.Empty;
        public int? MaterialId { get; set; }
    }

    public class ConversationDto
    {
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public MessageDto? LastMessage { get; set; }
        public int UnreadCount { get; set; }
    }
}
