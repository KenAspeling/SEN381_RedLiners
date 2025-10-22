using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("likes")]
    public class Like
    {
        [Key]
        [Column("like_id")]
        public int LikeId { get; set; }

        [Column("user_id")]
        public int? UserId { get; set; }

        [Column("post_id")]
        public int? PostId { get; set; }

        [Column("time_created")]
        public DateTime TimeCreated { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey("UserId")]
        public virtual User? User { get; set; }

        [ForeignKey("PostId")]
        public virtual Post? Post { get; set; }
    }
}
