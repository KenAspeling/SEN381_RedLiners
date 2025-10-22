using CampusLearnBackend.DTOs;

namespace CampusLearnBackend.Services
{
    public interface IAuthService
    {
        Task<AuthResponseDto?> RegisterAsync(RegisterDto registerDto);
        Task<AuthResponseDto?> LoginAsync(LoginDto loginDto);
        Task<UserDto?> GetUserByIdAsync(int userId);
        Task<UserDto?> GetUserByEmailAsync(string email);
        Task<UserDto?> UpdateProfileAsync(int userId, UpdateProfileDto updateDto);
        Task<bool> RequestPasswordResetAsync(string email);
        Task<bool> VerifyResetCodeAsync(string email, string code);
        Task<bool> ResetPasswordAsync(string email, string code, string newPassword);
        Task<bool> IsTutorAsync(int userId);
        Task<int?> GetAccessLevelAsync(int userId);
        string GenerateJwtToken(UserDto user);
        int? GetUserIdFromToken(string token);
    }
}