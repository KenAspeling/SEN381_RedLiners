using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using CampusLearnBackend.Data;
using CampusLearnBackend.Models;
using CampusLearnBackend.Services;

namespace CampusLearnBackend.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class MaterialsController : ControllerBase
    {
        private readonly CampusLearnContext _context;
        private readonly IAuthService _authService;
        private const long MaxFileSize = 10 * 1024 * 1024; // 10 MB
        private static readonly string[] AllowedExtensions = { ".pdf", ".doc", ".docx", ".txt", ".jpg", ".jpeg", ".png" };

        public MaterialsController(CampusLearnContext context, IAuthService authService)
        {
            _context = context;
            _authService = authService;
        }

        // POST: api/materials/upload
        [HttpPost("upload")]
        [RequestSizeLimit(10 * 1024 * 1024)] // 10 MB limit
        public async Task<ActionResult<object>> UploadFile(IFormFile file, [FromForm] string title)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null)
                    return Unauthorized();

                // Validate file
                if (file == null || file.Length == 0)
                    return BadRequest("No file provided");

                if (file.Length > MaxFileSize)
                    return BadRequest($"File size exceeds maximum allowed size of {MaxFileSize / (1024 * 1024)} MB");

                var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                if (!AllowedExtensions.Contains(extension))
                    return BadRequest($"File type not allowed. Allowed types: {string.Join(", ", AllowedExtensions)}");

                // Read file data
                byte[] fileData;
                using (var memoryStream = new MemoryStream())
                {
                    await file.CopyToAsync(memoryStream);
                    fileData = memoryStream.ToArray();
                }

                // Create material record
                var material = new Material
                {
                    Title = string.IsNullOrWhiteSpace(title) ? file.FileName : title,
                    FileName = file.FileName,
                    FileType = file.ContentType,
                    FileSize = file.Length,
                    FileData = fileData,
                    TimeCreated = DateTime.UtcNow
                };

                _context.Materials.Add(material);
                await _context.SaveChangesAsync();

                Console.WriteLine($"[MATERIAL] File uploaded: {file.FileName} ({file.Length} bytes) - Material ID: {material.MaterialId}");

                return Ok(new
                {
                    materialId = material.MaterialId,
                    title = material.Title,
                    fileName = material.FileName,
                    fileType = material.FileType,
                    fileSize = material.FileSize,
                    timeCreated = material.TimeCreated
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error uploading file: {ex.Message}");
                return StatusCode(500, $"Error uploading file: {ex.Message}");
            }
        }

        // GET: api/materials/5/download
        [HttpGet("{id}/download")]
        public async Task<IActionResult> DownloadFile(int id)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null)
                    return Unauthorized();

                var material = await _context.Materials
                    .FirstOrDefaultAsync(m => m.MaterialId == id);

                if (material == null)
                    return NotFound("File not found");

                if (material.FileData == null || material.FileData.Length == 0)
                    return NotFound("File data not available");

                Console.WriteLine($"[MATERIAL] File download: {material.FileName} ({material.FileSize} bytes) - Material ID: {material.MaterialId}");

                // Return file with appropriate content type
                return File(
                    material.FileData,
                    material.FileType ?? "application/octet-stream",
                    material.FileName ?? $"file_{material.MaterialId}"
                );
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error downloading file: {ex.Message}");
                return StatusCode(500, $"Error downloading file: {ex.Message}");
            }
        }

        // GET: api/materials/5
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetMaterialInfo(int id)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId == null)
                    return Unauthorized();

                var material = await _context.Materials
                    .FirstOrDefaultAsync(m => m.MaterialId == id);

                if (material == null)
                    return NotFound("Material not found");

                return Ok(new
                {
                    materialId = material.MaterialId,
                    title = material.Title,
                    fileName = material.FileName,
                    fileType = material.FileType,
                    fileSize = material.FileSize,
                    timeCreated = material.TimeCreated
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting material info: {ex.Message}");
                return StatusCode(500, $"Error getting material info: {ex.Message}");
            }
        }

        // Helper method
        private int? GetCurrentUserId()
        {
            var authHeader = Request.Headers["Authorization"].FirstOrDefault();
            if (authHeader == null || !authHeader.StartsWith("Bearer "))
                return null;

            var token = authHeader.Substring("Bearer ".Length).Trim();
            return _authService.GetUserIdFromToken(token);
        }
    }
}
