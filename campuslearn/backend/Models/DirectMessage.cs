using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("direct_messages")]
    public class DirectMessage
    {
        [Key]
        [Column("message_id")]
        public int MessageId { get; set; }

        [Column("sender_id")]
        public int? SenderId { get; set; }

        [Column("recipient_id")]
        public int? RecipientId { get; set; }

        [Required]
        [Column("content")]
        public string Content { get; set; } = string.Empty;

        [Column("time_created")]
        public DateTime TimeCreated { get; set; } = DateTime.UtcNow;

        [Column("read")]
        public bool Read { get; set; } = false;

        [Column("material_id")]
        public int? MaterialId { get; set; }

        // Navigation properties
        [ForeignKey("SenderId")]
        public virtual User? Sender { get; set; }

        [ForeignKey("RecipientId")]
        public virtual User? Recipient { get; set; }

        [ForeignKey("MaterialId")]
        public virtual Material? Material { get; set; }
    }
}
