using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    public class Topic
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(255)]
        public string Title { get; set; } = string.Empty;

        [Required]
        public string Content { get; set; } = string.Empty;

        [Required]
        public int UserId { get; set; }

        public int ViewCount { get; set; } = 0;
        
        public bool IsAnnouncement { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey("UserId")]
        public virtual User User { get; set; } = null!;
        
        public virtual ICollection<Comment> Comments { get; set; } = new List<Comment>();
        public virtual ICollection<TopicLike> TopicLikes { get; set; } = new List<TopicLike>();

        // Computed properties
        [NotMapped]
        public int LikeCount => TopicLikes?.Count ?? 0;

        [NotMapped]
        public int CommentCount => Comments?.Count ?? 0;

        [NotMapped]
        public string AuthorName => User?.Name ?? "Unknown";

        [NotMapped]
        public string AuthorEmail => User?.Email ?? "unknown@example.com";
    }
}