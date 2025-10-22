using System.ComponentModel.DataAnnotations;

namespace CampusLearn.API.DTOs
{
    public class MaterialUploadDto
    {
        [Required]
        public IFormFile File { get; set; } = null!;

        public string? Title { get; set; }

    }
}
