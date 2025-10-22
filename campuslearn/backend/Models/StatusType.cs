using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("status_type")]
    public class StatusType
    {
        [Key]
        [Column("status_id")]
        public int StatusId { get; set; }

        [Required]
        [StringLength(50)]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        // Navigation property
        public virtual ICollection<QueryTicket> QueryTickets { get; set; } = new List<QueryTicket>();
    }

    /// <summary>
    /// Status type constants for easier use in code
    /// </summary>
    public static class StatusTypes
    {
        public const int Sent = 1;
        public const int Received = 2;
        public const int Responded = 3;
    }
}
