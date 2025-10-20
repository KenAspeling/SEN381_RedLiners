using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    public class User
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        [StringLength(255)]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string EncryptedPassword { get; set; } = string.Empty;

        public bool IsTutor { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<Topic> Topics { get; set; } = new List<Topic>();
        public virtual ICollection<Comment> Comments { get; set; } = new List<Comment>();
        public virtual ICollection<TopicLike> TopicLikes { get; set; } = new List<TopicLike>();
        public virtual ICollection<CommentLike> CommentLikes { get; set; } = new List<CommentLike>();
        public virtual Tutor? Tutor { get; set; }
    }
}