using CampusLearn.API.Data;
using CampusLearn.API.DTOs;
using CampusLearn.API.Models;
using CampusLearn.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CampusLearn.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MaterialsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IFileStorageService _fileStorage;
        private readonly ILogger<MaterialsController> _logger;

        public MaterialsController(
            ApplicationDbContext context,
            IFileStorageService fileStorage,
            ILogger<MaterialsController> logger)
        {
            _context = context;
            _fileStorage = fileStorage;
            _logger = logger;
        }

        /// <summary>
        /// Upload a material file (PDF, image, video, document)
        /// </summary>
        [HttpPost("upload")]
        [Authorize]
        public async Task<IActionResult> UploadMaterial([FromForm] MaterialUploadDto dto)
        {
            if (dto.File == null || dto.File.Length == 0)
                return BadRequest(new { message = "No file provided" });

            // Validate file size
            if (dto.File.Length > 52428800) // 50MB
                return BadRequest(new { message = "File size exceeds 50MB limit" });

            // Validate file type
            var allowedTypes = new[] {
            "application/pdf",
            "image/jpeg",
            "image/png",
            "video/mp4",
            "audio/mpeg"
        };
            if (!allowedTypes.Contains(dto.File.ContentType))
                return BadRequest(new { message = "File type not allowed" });

            try
            {
                // Save file to disk
                var (storedFileName, storedPath) = await _fileStorage.SaveFileAsync(
                    dto.File,
                    null // No user ID needed in file path
                );

                // Create material record
                var material = new Material
                {
                    Title = dto.Title ?? dto.File.FileName,
                    Url = $"/uploads/{storedFileName}",
                    TimeCreated = DateTime.UtcNow
                };

                _context.Materials.Add(material);
                await _context.SaveChangesAsync();

                // Save metadata to JSON file
                await _fileStorage.SaveMetadataAsync(storedFileName, new MaterialMetadata
                {
                    MaterialId = material.MaterialId,
                    OriginalFileName = dto.File.FileName,
                    ContentType = dto.File.ContentType,
                    FileSizeBytes = dto.File.Length,
                    Status = MaterialStatus.Available,
                    ProcessedAt = DateTime.UtcNow
                });

                _logger.LogInformation(
                    "Material {MaterialId} uploaded: {FileName}",
                    material.MaterialId,
                    dto.File.FileName
                );

                return CreatedAtAction(
                    nameof(GetMaterial),
                    new { id = material.MaterialId },
                    new MaterialResponseDto
                    {
                        MaterialId = material.MaterialId,
                        Title = material.Title,
                        Url = material.Url,
                        OriginalFileName = dto.File.FileName,
                        ContentType = dto.File.ContentType,
                        FileSizeFormatted = FormatFileSize(dto.File.Length),
                        TimeCreated = material.TimeCreated
                    }
                );
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error uploading material");
                return StatusCode(500, new { message = "Error uploading file" });
            }
        }

        /// <summary>
        /// Download a material file by ID
        /// </summary>
        [HttpGet("{id}/download")]
        [Authorize]
        public async Task<IActionResult> DownloadMaterial(int id)
        {
            var material = await _context.Materials.FindAsync(id);
            if (material == null)
                return NotFound(new { message = "Material not found" });

            try
            {
                // Extract filename from URL
                var fileName = Path.GetFileName(material.Url);
                var fileBytes = await _fileStorage.GetFileAsync(fileName);

                // Load metadata to get content type
                var metadata = await _fileStorage.GetMetadataAsync(fileName);
                var contentType = metadata?.ContentType ?? "application/octet-stream";
                var originalFileName = metadata?.OriginalFileName ?? fileName;

                _logger.LogInformation(
                    "Material {MaterialId} downloaded",
                    material.MaterialId
                );

                return File(fileBytes, contentType, originalFileName);
            }
            catch (FileNotFoundException)
            {
                _logger.LogWarning("File not found for material {MaterialId}", id);
                return NotFound(new { message = "File not found" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error downloading material {MaterialId}", id);
                return StatusCode(500, new { message = "Error downloading file" });
            }
        }

        /// Get material details by ID
        [HttpGet("{id}")]
        public async Task<IActionResult> GetMaterial(int id)
        {
            var material = await _context.Materials.FindAsync(id);
            if (material == null)
                return NotFound(new { message = "Material not found" });

            // Load metadata
            var fileName = Path.GetFileName(material.Url);
            var metadata = await _fileStorage.GetMetadataAsync(fileName);

            return Ok(new MaterialResponseDto
            {
                MaterialId = material.MaterialId,
                Title = material.Title,
                Url = material.Url,
                OriginalFileName = metadata?.OriginalFileName,
                ContentType = metadata?.ContentType,
                FileSizeFormatted = metadata != null ? FormatFileSize(metadata.FileSizeBytes) : null,
                TimeCreated = material.TimeCreated,
                Status = metadata?.Status.ToString()
            });
        }

       
        /// List all materials with pagination
        [HttpGet]
        public async Task<IActionResult> GetMaterials(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            if (pageSize > 50) pageSize = 50;

            var totalCount = await _context.Materials.CountAsync();

            var materials = await _context.Materials
                .OrderByDescending(m => m.TimeCreated)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var responseDtos = new List<MaterialResponseDto>();
            foreach (var material in materials)
            {
                var fileName = Path.GetFileName(material.Url);
                var metadata = await _fileStorage.GetMetadataAsync(fileName);

                responseDtos.Add(new MaterialResponseDto
                {
                    MaterialId = material.MaterialId,
                    Title = material.Title,
                    Url = material.Url,
                    OriginalFileName = metadata?.OriginalFileName,
                    ContentType = metadata?.ContentType,
                    FileSizeFormatted = metadata != null ? FormatFileSize(metadata.FileSizeBytes) : null,
                    TimeCreated = material.TimeCreated,
                    Status = metadata?.Status.ToString()
                });
            }

            return Ok(new
            {
                items = responseDtos,
                totalCount,
                page,
                pageSize,
                totalPages = (int)Math.Ceiling(totalCount / (double)pageSize)
            });
        }

        
        /// Delete a material
        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> DeleteMaterial(int id)
        {
            var material = await _context.Materials.FindAsync(id);
            if (material == null)
                return NotFound(new { message = "Material not found" });

            try
            {
                // Delete from database
                _context.Materials.Remove(material);
                await _context.SaveChangesAsync();

                // Delete file from disk 
                var fileName = Path.GetFileName(material.Url);
                _ = Task.Run(async () =>
                {
                    await _fileStorage.DeleteFileAsync(fileName);
                    await _fileStorage.DeleteMetadataAsync(fileName);
                });

                _logger.LogInformation("Material {MaterialId} deleted", id);

                return Ok(new { message = "Material deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting material {MaterialId}", id);
                return StatusCode(500, new { message = "Error deleting material" });
            }
        }

        private string FormatFileSize(long bytes)
        {
            string[] sizes = { "B", "KB", "MB", "GB", "TB" };
            double len = bytes;
            int order = 0;
            while (len >= 1024 && order < sizes.Length - 1)
            {
                order++;
                len = len / 1024;
            }
            return $"{len:0.##} {sizes[order]}";
        }
    }
       
}
