using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    public class Comment
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int TopicId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        public string Content { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey("TopicId")]
        public virtual Topic Topic { get; set; } = null!;

        [ForeignKey("UserId")]
        public virtual User User { get; set; } = null!;

        public virtual ICollection<CommentLike> CommentLikes { get; set; } = new List<CommentLike>();

        // Computed properties
        [NotMapped]
        public int LikeCount => CommentLikes?.Count ?? 0;

        [NotMapped]
        public string AuthorName => User?.Name ?? "Unknown";

        [NotMapped]
        public string AuthorEmail => User?.Email ?? "unknown@example.com";
    }
}