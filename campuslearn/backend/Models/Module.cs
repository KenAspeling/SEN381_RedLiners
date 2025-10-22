using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("modules")]
    public class Module
    {
        [Key]
        [Column("module_id")]
        public int ModuleId { get; set; }

        [Required]
        [StringLength(100)]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [StringLength(50)]
        [Column("tag")]
        public string? Tag { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        // Navigation properties
        public virtual ICollection<UserModule> UserModules { get; set; } = new List<UserModule>();
        public virtual ICollection<Post> Posts { get; set; } = new List<Post>();
        public virtual ICollection<QueryTicket> QueryTickets { get; set; } = new List<QueryTicket>();
    }
}
