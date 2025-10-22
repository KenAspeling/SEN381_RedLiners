using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("subscribable_type")]
    public class SubscribableType
    {
        [Key]
        [Column("type_id")]
        public int TypeId { get; set; }

        [Required]
        [StringLength(50)]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        // Navigation property
        public virtual ICollection<Subscription> Subscriptions { get; set; } = new List<Subscription>();
    }

    /// <summary>
    /// Subscribable type constants for easier use in code
    /// </summary>
    public static class SubscribableTypes
    {
        public const int Topic = 1;
        public const int Module = 2;
    }
}
