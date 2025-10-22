using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("notifications")]
    public class Notification
    {
        [Key]
        [Column("notification_id")]
        public int NotificationId { get; set; }

        [Column("user_id")]
        public int UserId { get; set; }

        [Required]
        [StringLength(100)]
        [Column("title")]
        public string Title { get; set; } = string.Empty;

        [Required]
        [StringLength(500)]
        [Column("message")]
        public string Message { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        [Column("type")]
        public string Type { get; set; } = string.Empty; // "comment", "new_post", "system", etc.

        [Column("related_id")]
        public int? RelatedId { get; set; } // Topic ID, Post ID, etc.

        [Column("is_read")]
        public bool IsRead { get; set; } = false;

        [Column("time_created")]
        public DateTime TimeCreated { get; set; } = DateTime.UtcNow;

        // Navigation property
        [ForeignKey("UserId")]
        public virtual User? User { get; set; }
    }

    /// <summary>
    /// Notification type constants for easier use in code
    /// </summary>
    public static class NotificationTypes
    {
        public const string Comment = "comment";
        public const string NewPost = "new_post";
        public const string NewTopic = "new_topic";
        public const string System = "system";
    }
}
