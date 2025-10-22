using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("query_ticket")]
    public class QueryTicket
    {
        [Key]
        [Column("ticket_id")]
        public int TicketId { get; set; }

        [Column("user_id")]
        public int? UserId { get; set; }

        [Column("module_id")]
        public int? ModuleId { get; set; }

        [Required]
        [StringLength(200)]
        [Column("title")]
        public string Title { get; set; } = string.Empty;

        [Required]
        [Column("content")]
        public string Content { get; set; } = string.Empty;

        [Column("status")]
        public int? Status { get; set; }

        [Column("time_created")]
        public DateTime TimeCreated { get; set; } = DateTime.UtcNow;

        [Column("material_id")]
        public int? MaterialId { get; set; }

        // Navigation properties
        [ForeignKey("UserId")]
        public virtual User? User { get; set; }

        [ForeignKey("ModuleId")]
        public virtual Module? Module { get; set; }

        [ForeignKey("Status")]
        public virtual StatusType? StatusType { get; set; }

        [ForeignKey("MaterialId")]
        public virtual Material? Material { get; set; }

        public virtual ICollection<Response> Responses { get; set; } = new List<Response>();
    }
}
