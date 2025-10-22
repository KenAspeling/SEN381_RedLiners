namespace CampusLearnBackend.DTOs
{
    public class UserDto
    {
        public int UserId { get; set; }
        public string Email { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Surname { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public DateTime TimeCreated { get; set; }
        public int? AccessLevel { get; set; }
        public string? AccessLevelName { get; set; } // "student", "tutor", "admin"
        public string? Degree { get; set; }
        public int? YearOfStudy { get; set; }
        public List<int> ModuleIds { get; set; } = new List<int>();
    }

    public class RegisterDto
    {
        public string Email { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Surname { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string Password { get; set; } = string.Empty;
        public string? Degree { get; set; }
        public int? YearOfStudy { get; set; }
        public List<int> ModuleIds { get; set; } = new List<int>();
    }

    public class LoginDto
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }

    public class AuthResponseDto
    {
        public string Token { get; set; } = string.Empty;
        public UserDto User { get; set; } = null!;
        public DateTime ExpiresAt { get; set; }
    }

    public class UpdateProfileDto
    {
        public string? Name { get; set; }
        public string? Surname { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Degree { get; set; }
        public int? YearOfStudy { get; set; }
    }

    public class ForgotPasswordDto
    {
        public string Email { get; set; } = string.Empty;
    }

    public class VerifyResetCodeDto
    {
        public string Email { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
    }

    public class ResetPasswordDto
    {
        public string Email { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
    }
}