using CampusLearnBackend.DTOs;

namespace CampusLearnBackend.Services
{
    public interface IAuthService
    {
        Task<AuthResponseDto?> RegisterAsync(RegisterDto registerDto);
        Task<AuthResponseDto?> LoginAsync(LoginDto loginDto);
        Task<UserDto?> GetUserByIdAsync(int userId);
        Task<UserDto?> GetUserByEmailAsync(string email);
        Task<bool> IsTutorAsync(int userId);
        string GenerateJwtToken(UserDto user);
        int? GetUserIdFromToken(string token);
    }
}