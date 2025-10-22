using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("post_type")]
    public class PostType
    {
        [Key]
        [Column("type_id")]
        public int TypeId { get; set; }

        [Required]
        [StringLength(50)]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        // Navigation property
        public virtual ICollection<Post> Posts { get; set; } = new List<Post>();
    }

    /// <summary>
    /// Post type constants for easier use in code
    /// </summary>
    public static class PostTypes
    {
        public const int Comment = 1;
        public const int Post = 2;
        public const int Topic = 3;
    }
}
