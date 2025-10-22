using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("subscriptions")]
    public class Subscription
    {
        [Key]
        [Column("subscription_id")]
        public int SubscriptionId { get; set; }

        [Column("user_id")]
        public int? UserId { get; set; }

        [Column("subscribable_type")]
        public int? SubscribableType { get; set; }

        [Column("subscribable_id")]
        public int SubscribableId { get; set; }

        [Column("time_created")]
        public DateTime TimeCreated { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey("UserId")]
        public virtual User? User { get; set; }

        [ForeignKey("SubscribableType")]
        public virtual SubscribableType? SubscribableTypeNavigation { get; set; }

        // Note: SubscribableId is polymorphic - can reference posts.post_id or modules.module_id
        // No direct foreign key navigation property because it's polymorphic
    }
}
