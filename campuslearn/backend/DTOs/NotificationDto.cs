namespace CampusLearnBackend.DTOs
{
    public class NotificationDto
    {
        public int NotificationId { get; set; }
        public int UserId { get; set; }
        public string Type { get; set; } = string.Empty; // "comment", "new_post", "new_topic", "like", "message", "ticket_response", "new_ticket"
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public int? RelatedId { get; set; } // ID of the comment/topic/message/ticket
        public DateTime TimeCreated { get; set; }
        public bool IsRead { get; set; }
    }

    public class CreateNotificationDto
    {
        public int UserId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public int? RelatedId { get; set; }
    }
}
