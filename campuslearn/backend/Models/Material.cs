using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("materials")]
    public class Material
    {
        [Key]
        [Column("material_id")]
        public int MaterialId { get; set; }

        [Required]
        [StringLength(100)]
        [Column("title")]
        public string Title { get; set; } = string.Empty;

        [Column("url")]
        public string? Url { get; set; }

        [Column("file_name")]
        [StringLength(255)]
        public string? FileName { get; set; }

        [Column("file_type")]
        [StringLength(100)]
        public string? FileType { get; set; }

        [Column("file_size")]
        public long? FileSize { get; set; }

        [Column("file_data")]
        public byte[]? FileData { get; set; }

        [Column("time_created")]
        public DateTime TimeCreated { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<Post> Posts { get; set; } = new List<Post>();
        public virtual ICollection<DirectMessage> DirectMessages { get; set; } = new List<DirectMessage>();
        public virtual ICollection<QueryTicket> QueryTickets { get; set; } = new List<QueryTicket>();
        public virtual ICollection<Response> Responses { get; set; } = new List<Response>();
    }
}
