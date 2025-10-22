namespace CampusLearnBackend.DTOs
{
    public class PostDto
    {
        // New field names
        public int PostId { get; set; }
        public int? UserId { get; set; }
        public int? ParentPostId { get; set; }
        public string? Title { get; set; } // Nullable - comments don't have titles
        public string Content { get; set; } = string.Empty;
        public int? Type { get; set; }
        public string? TypeName { get; set; } // "Comment", "Post", "Topic"
        public int? Module { get; set; }
        public string? ModuleName { get; set; }
        public DateTime TimeCreated { get; set; }
        public int? MaterialId { get; set; }
        public string? MaterialTitle { get; set; }
        public int LikeCount { get; set; }
        public int CommentCount { get; set; }
        public bool IsLikedByCurrentUser { get; set; }
        public bool IsSubscribedByCurrentUser { get; set; }
        public bool IsAnonymous { get; set; }

        // Legacy field names for backward compatibility with Flutter Topic model
        public int Id => PostId;
        public string AuthorName { get; set; } = "Student"; // User's access level name (Student/Tutor/Admin)
        public string AuthorEmail { get; set; } = string.Empty;
        public DateTime CreatedAt => TimeCreated;
        public DateTime UpdatedAt => TimeCreated; // We don't track updates separately
        public int ViewCount => 0; // We don't track views in new schema
        public bool IsLiked => IsLikedByCurrentUser;
        public bool IsAnnouncement => Type == 3; // Type 3 = Topic (could be announcement)
    }

    public class CreatePostDto
    {
        public int? ParentPostId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public int Type { get; set; } // 1=Comment, 2=Post, 3=Topic
        public int? Module { get; set; }
        public int? MaterialId { get; set; }
        public bool IsAnonymous { get; set; } = false;
    }

    public class UpdatePostDto
    {
        public string? Title { get; set; }
        public string? Content { get; set; }
    }
}
