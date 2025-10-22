using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CampusLearnBackend.Models
{
    [Table("fcm_tokens")]
    public class FcmToken
    {
        [Key]
        [Column("token_id")]
        public int TokenId { get; set; }

        [Column("user_id")]
        public int UserId { get; set; }

        [Required]
        [StringLength(500)]
        [Column("fcm_token")]
        public string Token { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        [Column("device_type")]
        public string DeviceType { get; set; } = "android";

        [StringLength(200)]
        [Column("device_info")]
        public string? DeviceInfo { get; set; }

        [Column("is_active")]
        public bool IsActive { get; set; } = true;

        [Column("time_created")]
        public DateTime TimeCreated { get; set; } = DateTime.UtcNow;

        [Column("time_updated")]
        public DateTime TimeUpdated { get; set; } = DateTime.UtcNow;

        [ForeignKey("UserId")]
        public virtual User? User { get; set; }
    }

    public static class DeviceTypes
    {
        public const string Android = "android";
        public const string iOS = "ios";
        public const string Web = "web";
    }
}
