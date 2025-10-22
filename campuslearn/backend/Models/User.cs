using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("users")]
    public class User
    {
        [Key]
        [Column("user_id")]
        public int UserId { get; set; }

        [Required]
        [EmailAddress]
        [StringLength(255)]
        [Column("email")]
        public string Email { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        [Column("surname")]
        public string Surname { get; set; } = string.Empty;

        [StringLength(20)]
        [Column("phone_number")]
        public string? PhoneNumber { get; set; }

        [Required]
        [Column("encrypted_password")]
        public string EncryptedPassword { get; set; } = string.Empty;

        [Column("access_level")]
        public int? AccessLevel { get; set; }

        [StringLength(100)]
        [Column("degree")]
        public string? Degree { get; set; }

        [Column("year_of_study")]
        public int? YearOfStudy { get; set; }

        [Column("time_created")]
        public DateTime TimeCreated { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey("AccessLevel")]
        public virtual AccessType? AccessType { get; set; }

        public virtual ICollection<UserModule> UserModules { get; set; } = new List<UserModule>();
        public virtual ICollection<Post> Posts { get; set; } = new List<Post>();
        public virtual ICollection<Like> Likes { get; set; } = new List<Like>();
        public virtual ICollection<Subscription> Subscriptions { get; set; } = new List<Subscription>();
        public virtual ICollection<DirectMessage> SentMessages { get; set; } = new List<DirectMessage>();
        public virtual ICollection<DirectMessage> ReceivedMessages { get; set; } = new List<DirectMessage>();
        public virtual ICollection<QueryTicket> QueryTickets { get; set; } = new List<QueryTicket>();
        public virtual ICollection<Response> Responses { get; set; } = new List<Response>();
    }
}
