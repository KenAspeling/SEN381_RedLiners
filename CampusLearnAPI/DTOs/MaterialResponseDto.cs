namespace CampusLearn.API.DTOs
{
    public class MaterialResponseDto
    {
        public int MaterialId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Url { get; set; } = string.Empty;
        public string? OriginalFileName { get; set; }
        public string? ContentType { get; set; }
        public string? FileSizeFormatted { get; set; }
        public DateTime TimeCreated { get; set; }
        public string? Status { get; set; }
    }
}
