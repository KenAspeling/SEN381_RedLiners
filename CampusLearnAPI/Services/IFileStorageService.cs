using CampusLearn.API.DTOs;

namespace CampusLearn.API.Services
{
    public interface IFileStorageService
    {
        Task<(string fileName, string fullPath)> SaveFileAsync(IFormFile file, string? userId);
        Task<byte[]> GetFileAsync(string fileName);
        Task DeleteFileAsync(string fileName);
        Task SaveMetadataAsync(string fileName, MaterialMetadata metadata);
        Task<MaterialMetadata?> GetMetadataAsync(string fileName);
        Task DeleteMetadataAsync(string fileName);
    }
}
