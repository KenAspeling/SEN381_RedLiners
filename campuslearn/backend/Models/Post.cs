using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("posts")]
    public class Post
    {
        [Key]
        [Column("post_id")]
        public int PostId { get; set; }

        [Column("user_id")]
        public int? UserId { get; set; }

        [Column("parent_post_id")]
        public int? ParentPostId { get; set; }

        [StringLength(255)]
        [Column("title")]
        public string? Title { get; set; }

        [Required]
        [Column("content")]
        public string Content { get; set; } = string.Empty;

        [Column("type")]
        public int? Type { get; set; }

        [Column("module")]
        public int? Module { get; set; }

        [Column("time_created")]
        public DateTime TimeCreated { get; set; } = DateTime.UtcNow;

        [Column("material_id")]
        public int? MaterialId { get; set; }

        [Column("is_anonymous")]
        public bool IsAnonymous { get; set; } = false;

        // Navigation properties
        [ForeignKey("UserId")]
        public virtual User? User { get; set; }

        [ForeignKey("ParentPostId")]
        public virtual Post? ParentPost { get; set; }

        [ForeignKey("Type")]
        public virtual PostType? PostType { get; set; }

        [ForeignKey("Module")]
        public virtual Module? ModuleNavigation { get; set; }

        [ForeignKey("MaterialId")]
        public virtual Material? Material { get; set; }

        // Child posts (comments/replies)
        public virtual ICollection<Post> ChildPosts { get; set; } = new List<Post>();

        public virtual ICollection<Like> Likes { get; set; } = new List<Like>();
    }
}
