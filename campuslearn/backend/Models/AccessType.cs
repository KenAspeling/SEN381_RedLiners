using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("access_type")]
    public class AccessType
    {
        [Key]
        [Column("access_id")]
        public int AccessId { get; set; }

        [Required]
        [StringLength(50)]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        // Navigation property
        public virtual ICollection<User> Users { get; set; } = new List<User>();
    }

    /// <summary>
    /// Access level constants for easier use in code
    /// </summary>
    public static class AccessLevels
    {
        public const int Student = 1;
        public const int Tutor = 2;
        public const int Admin = 3;
    }
}
