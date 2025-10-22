using CampusLearn.API.DTOs;
using System.Text.Json;

namespace CampusLearn.API.Services
{
    public class FileStorageService : IFileStorageService
    {
        private readonly string _uploadPath;
        private readonly ILogger<FileStorageService> _logger;

        public FileStorageService(IWebHostEnvironment environment, ILogger<FileStorageService> logger)
        {
            _uploadPath = Path.Combine(environment.ContentRootPath, "uploads");
            _logger = logger;

            if (!Directory.Exists(_uploadPath))
                Directory.CreateDirectory(_uploadPath);
        }

        public async Task<(string fileName, string fullPath)> SaveFileAsync(IFormFile file, string? userId)
        {
            var fileName = $"{Guid.NewGuid()}_{file.FileName}";
            var fullPath = Path.Combine(_uploadPath, fileName);

            using (var stream = new FileStream(fullPath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            _logger.LogInformation("File saved: {FileName}", fileName);
            return (fileName, fullPath);
        }

        public async Task<byte[]> GetFileAsync(string fileName)
        {
            var fullPath = Path.Combine(_uploadPath, fileName);

            if (!File.Exists(fullPath))
                throw new FileNotFoundException($"File not found: {fileName}");

            return await File.ReadAllBytesAsync(fullPath);
        }

        public async Task DeleteFileAsync(string fileName)
        {
            var fullPath = Path.Combine(_uploadPath, fileName);

            if (File.Exists(fullPath))
            {
                await Task.Run(() => File.Delete(fullPath));
                _logger.LogInformation("File deleted: {FileName}", fileName);
            }
        }

        public async Task SaveMetadataAsync(string fileName, MaterialMetadata metadata)
        {
            var metadataPath = Path.Combine(_uploadPath, $"{fileName}.json");
            var json = JsonSerializer.Serialize(metadata, new JsonSerializerOptions
            {
                WriteIndented = true
            });
            await File.WriteAllTextAsync(metadataPath, json);
        }

        public async Task<MaterialMetadata?> GetMetadataAsync(string fileName)
        {
            var metadataPath = Path.Combine(_uploadPath, $"{fileName}.json");

            if (!File.Exists(metadataPath))
                return null;

            var json = await File.ReadAllTextAsync(metadataPath);
            return JsonSerializer.Deserialize<MaterialMetadata>(json);
        }

        public async Task DeleteMetadataAsync(string fileName)
        {
            var metadataPath = Path.Combine(_uploadPath, $"{fileName}.json");

            if (File.Exists(metadataPath))
            {
                await Task.Run(() => File.Delete(metadataPath));
            }
        }
    }
}
