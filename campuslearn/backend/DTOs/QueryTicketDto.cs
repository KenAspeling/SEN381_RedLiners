using System.ComponentModel.DataAnnotations;

namespace CampusLearnBackend.DTOs
{
    public class QueryTicketDto
    {
        public int TicketId { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public int ModuleId { get; set; }
        public string ModuleName { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public int Status { get; set; }
        public string StatusName { get; set; } = string.Empty;
        public DateTime TimeCreated { get; set; }
        public int? MaterialId { get; set; }

        // Material/File information (if exists)
        public string? FileName { get; set; }
        public string? FileType { get; set; }
        public long? FileSize { get; set; }

        // Response information (if exists)
        public int? ResponseId { get; set; }
        public string? ResponseContent { get; set; }
        public int? TutorId { get; set; }
        public string? TutorName { get; set; }
        public string? TutorEmail { get; set; }
        public DateTime? TimeResponded { get; set; }
    }

    public class CreateQueryTicketDto
    {
        [Required]
        [StringLength(200)]
        public string Title { get; set; } = string.Empty;

        [Required]
        public string Content { get; set; } = string.Empty;

        [Required]
        public int ModuleId { get; set; }

        public int? MaterialId { get; set; }
    }

    public class ClaimQueryTicketDto
    {
        [Required]
        public int TicketId { get; set; }
    }

    public class RespondToQueryTicketDto
    {
        [Required]
        public int TicketId { get; set; }

        [Required]
        public string Content { get; set; } = string.Empty;

        public int? MaterialId { get; set; }
    }
}
