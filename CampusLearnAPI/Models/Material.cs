using Azure;
using Microsoft.Extensions.Hosting;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Reflection;

namespace CampusLearn.API.Models
{
    public class Material
    {
        [Key]
        [Column("material_id")]
        public int MaterialId { get; set; }

        [Required]
        [Column("title")]
        public string Title { get; set; } = string.Empty;

        [Required]
        [Column("url")]
        public string Url { get; set; } = string.Empty;

        [Column("time_created")]
        public DateTime TimeCreated { get; set; }

        /*Foreign Keys
        public virtual ICollection<Post> Posts { get; set; } = new List<Post>();
        public virtual ICollection<Response> Responses { get; set; } = new List<Response>();
        public virtual ICollection<DirectMessage> DirectMessages { get; set; } = new List<DirectMessage>();
        */
        }

    public enum MaterialStatus
    {
        Uploading = 0,
        Processing = 1,
        Available = 2,
        Failed = 3,
        Deleted = 4
    }
}

