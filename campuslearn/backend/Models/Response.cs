using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("responses")]
    public class Response
    {
        [Key]
        [Column("response_id")]
        public int ResponseId { get; set; }

        [Column("query_id")]
        public int? QueryId { get; set; }

        [Column("user_id")]
        public int? UserId { get; set; }

        [Required]
        [Column("content")]
        public string Content { get; set; } = string.Empty;

        [Column("time_created")]
        public DateTime TimeCreated { get; set; } = DateTime.UtcNow;

        [Column("material_id")]
        public int? MaterialId { get; set; }

        // Navigation properties
        [ForeignKey("QueryId")]
        public virtual QueryTicket? QueryTicket { get; set; }

        [ForeignKey("UserId")]
        public virtual User? User { get; set; }

        [ForeignKey("MaterialId")]
        public virtual Material? Material { get; set; }
    }
}
