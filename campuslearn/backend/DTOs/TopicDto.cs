namespace CampusLearnBackend.DTOs
{
    public class TopicDto
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public string AuthorName { get; set; } = string.Empty;
        public string AuthorEmail { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public int LikeCount { get; set; }
        public int CommentCount { get; set; }
        public int ViewCount { get; set; }
        public bool IsLiked { get; set; } // Whether current user liked this topic
        // IsAnnouncement removed - column doesn't exist in database
    }

    public class CreateTopicDto
    {
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        // IsAnnouncement removed - column doesn't exist in database
    }

    public class UpdateTopicDto
    {
        public string? Title { get; set; }
        public string? Content { get; set; }
        // IsAnnouncement removed - column doesn't exist in database
    }
}