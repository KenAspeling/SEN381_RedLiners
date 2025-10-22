using CampusLearn.API.Models;

namespace CampusLearn.API.DTOs
{
    public class MaterialMetadata
    {
        public int MaterialId { get; set; }
        public string? OriginalFileName { get; set; }
        public string? ContentType { get; set; }
        public long FileSizeBytes { get; set; }
        public MaterialStatus Status { get; set; }
        public DateTime? ProcessedAt { get; set; }
        public string? ThumbnailPath { get; set; }
        public string? ErrorMessage { get; set; }
    }
}
