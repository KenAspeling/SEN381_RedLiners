namespace CampusLearnBackend.DTOs
{
    public class CommentDto
    {
        public int Id { get; set; }
        public int TopicId { get; set; }
        public string Content { get; set; } = string.Empty;
        public string AuthorName { get; set; } = string.Empty;
        public string AuthorEmail { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public int LikeCount { get; set; }
        public bool IsLiked { get; set; } // Whether current user liked this comment
    }

    public class CreateCommentDto
    {
        public int TopicId { get; set; }
        public string Content { get; set; } = string.Empty;
    }

    public class UpdateCommentDto
    {
        public string Content { get; set; } = string.Empty;
    }
}