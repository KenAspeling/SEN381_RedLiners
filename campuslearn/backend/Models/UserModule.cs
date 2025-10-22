using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("user_module")]
    public class UserModule
    {
        [Key]
        [Column("user_id", Order = 0)]
        public int UserId { get; set; }

        [Key]
        [Column("module_id", Order = 1)]
        public int ModuleId { get; set; }

        // Navigation properties
        [ForeignKey("UserId")]
        public virtual User User { get; set; } = null!;

        [ForeignKey("ModuleId")]
        public virtual Module Module { get; set; } = null!;
    }
}
