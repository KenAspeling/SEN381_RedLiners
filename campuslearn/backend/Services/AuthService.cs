using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using BCrypt.Net;
using CampusLearnBackend.Data;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Models;

namespace CampusLearnBackend.Services
{
    public class AuthService : IAuthService
    {
        private readonly CampusLearnContext _context;
        private readonly IConfiguration _configuration;
        private readonly ICacheService _cache;
        private readonly IEmailService _emailService;

        public AuthService(CampusLearnContext context, IConfiguration configuration, ICacheService cache, IEmailService emailService)
        {
            _context = context;
            _configuration = configuration;
            _cache = cache;
            _emailService = emailService;
        }

        public async Task<AuthResponseDto?> RegisterAsync(RegisterDto registerDto)
        {
            // Validate email domain
            if (!registerDto.Email.EndsWith("@belgiumcampus.ac.za", StringComparison.OrdinalIgnoreCase))
            {
                throw new Exception("Email must end with @belgiumcampus.ac.za");
            }

            // Check if user already exists
            if (await _context.Users.AnyAsync(u => u.Email == registerDto.Email))
                return null;

            // Hash password
            var hashedPassword = BCrypt.Net.BCrypt.HashPassword(registerDto.Password);

            // Create user with Student access level by default
            var user = new User
            {
                Email = registerDto.Email,
                Name = registerDto.Name,
                Surname = registerDto.Surname,
                PhoneNumber = registerDto.PhoneNumber,
                EncryptedPassword = hashedPassword,
                AccessLevel = AccessLevels.Student, // Default to Student
                Degree = registerDto.Degree,
                YearOfStudy = registerDto.YearOfStudy
            };

            _context.Users.Add(user);

            // Enroll user in selected modules (atomic with user creation)
            if (registerDto.ModuleIds != null && registerDto.ModuleIds.Any())
            {
                foreach (var moduleId in registerDto.ModuleIds)
                {
                    // Verify module exists before enrolling
                    var moduleExists = await _context.Modules.AnyAsync(m => m.ModuleId == moduleId);
                    if (!moduleExists)
                    {
                        throw new Exception($"Module with ID {moduleId} does not exist");
                    }

                    _context.UserModules.Add(new UserModule
                    {
                        User = user, // Uses navigation property, EF will set UserId after SaveChanges
                        ModuleId = moduleId
                    });
                }
            }

            // Save user and module enrollments in one transaction (atomic)
            await _context.SaveChangesAsync();

            var userDto = await MapToUserDtoAsync(user);
            var token = GenerateJwtToken(userDto);

            return new AuthResponseDto
            {
                Token = token,
                User = userDto,
                ExpiresAt = DateTime.UtcNow.AddMinutes(GetJwtExpirationMinutes())
            };
        }

        public async Task<AuthResponseDto?> LoginAsync(LoginDto loginDto)
        {
            var user = await _context.Users
                .Include(u => u.AccessType)
                .Include(u => u.UserModules)
                .FirstOrDefaultAsync(u => u.Email == loginDto.Email);

            if (user == null || !BCrypt.Net.BCrypt.Verify(loginDto.Password, user.EncryptedPassword))
                return null;

            var userDto = await MapToUserDtoAsync(user);
            var token = GenerateJwtToken(userDto);

            return new AuthResponseDto
            {
                Token = token,
                User = userDto,
                ExpiresAt = DateTime.UtcNow.AddMinutes(GetJwtExpirationMinutes())
            };
        }

        public async Task<UserDto?> GetUserByIdAsync(int userId)
        {
            // Try to get from cache first
            var cacheKey = $"{CacheService.Keys.User}{userId}";
            var cachedUser = _cache.Get<UserDto>(cacheKey);

            if (cachedUser != null)
                return cachedUser;

            // If not in cache, fetch from database
            var user = await _context.Users
                .Include(u => u.AccessType)
                .Include(u => u.UserModules)
                .FirstOrDefaultAsync(u => u.UserId == userId);

            if (user == null)
                return null;

            var userDto = await MapToUserDtoAsync(user);

            // Store in cache
            _cache.Set(cacheKey, userDto, CacheService.Expiration.Users);

            return userDto;
        }

        public async Task<UserDto?> GetUserByEmailAsync(string email)
        {
            // No caching for email lookup (less frequently used)
            var user = await _context.Users
                .Include(u => u.AccessType)
                .Include(u => u.UserModules)
                .FirstOrDefaultAsync(u => u.Email == email);

            return user != null ? await MapToUserDtoAsync(user) : null;
        }

        public async Task<UserDto?> UpdateProfileAsync(int userId, UpdateProfileDto updateDto)
        {
            var user = await _context.Users
                .Include(u => u.AccessType)
                .Include(u => u.UserModules)
                .FirstOrDefaultAsync(u => u.UserId == userId);

            if (user == null)
                return null;

            // Update only the fields that are provided (not null)
            if (updateDto.Name != null)
                user.Name = updateDto.Name;

            if (updateDto.Surname != null)
                user.Surname = updateDto.Surname;

            if (updateDto.PhoneNumber != null)
                user.PhoneNumber = updateDto.PhoneNumber;

            if (updateDto.Degree != null)
                user.Degree = updateDto.Degree;

            if (updateDto.YearOfStudy.HasValue)
                user.YearOfStudy = updateDto.YearOfStudy.Value;

            await _context.SaveChangesAsync();

            // Invalidate cache for this user
            _cache.Remove($"user_{userId}");

            return await MapToUserDtoAsync(user);
        }

        public async Task<bool> RequestPasswordResetAsync(string email)
        {
            try
            {
                // Check if user exists
                var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
                if (user == null)
                {
                    // Don't reveal if email exists or not for security
                    return true;
                }

                // Generate 6-digit code
                var random = new Random();
                var code = random.Next(100000, 999999).ToString();

                // Store code in cache with 15-minute expiration
                var cacheKey = $"reset_code_{email}";
                _cache.Set(cacheKey, code, TimeSpan.FromMinutes(15));

                // Send password reset email
                var emailSent = await SendPasswordResetEmailAsync(user.Email, user.Name ?? "User", code);

                if (!emailSent)
                {
                    // Fallback to console logging if email fails
                    Console.WriteLine($"[EMAIL FAILED] Password Reset Code for {email}: {code}");
                    Console.WriteLine($"Code expires in 15 minutes");
                }

                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error requesting password reset: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> VerifyResetCodeAsync(string email, string code)
        {
            try
            {
                var cacheKey = $"reset_code_{email}";
                var storedCode = _cache.Get<string>(cacheKey);

                if (storedCode == null)
                {
                    return false; // Code expired or doesn't exist
                }

                return storedCode == code;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error verifying reset code: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> ResetPasswordAsync(string email, string code, string newPassword)
        {
            try
            {
                // Verify code first
                var isValidCode = await VerifyResetCodeAsync(email, code);
                if (!isValidCode)
                {
                    return false;
                }

                // Find user
                var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
                if (user == null)
                {
                    return false;
                }

                // Update password
                user.EncryptedPassword = BCrypt.Net.BCrypt.HashPassword(newPassword);
                await _context.SaveChangesAsync();

                // Remove the reset code from cache
                var cacheKey = $"reset_code_{email}";
                _cache.Remove(cacheKey);

                // Invalidate user cache
                _cache.Remove($"user_{user.UserId}");

                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error resetting password: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> IsTutorAsync(int userId)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            return user?.AccessLevel >= AccessLevels.Tutor;
        }

        public async Task<int?> GetAccessLevelAsync(int userId)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            return user?.AccessLevel;
        }

        public string GenerateJwtToken(UserDto user)
        {
            var secretKey = _configuration["JwtSettings:SecretKey"];
            var issuer = _configuration["JwtSettings:Issuer"];
            var audience = _configuration["JwtSettings:Audience"];

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey!));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim("AccessLevel", user.AccessLevel?.ToString() ?? "0")
            };

            // Add role claim based on access level
            if (user.AccessLevel >= AccessLevels.Admin)
                claims.Add(new Claim(ClaimTypes.Role, "Admin"));
            else if (user.AccessLevel >= AccessLevels.Tutor)
                claims.Add(new Claim(ClaimTypes.Role, "Tutor"));
            else
                claims.Add(new Claim(ClaimTypes.Role, "Student"));

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(GetJwtExpirationMinutes()),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        public int? GetUserIdFromToken(string token)
        {
            try
            {
                var tokenHandler = new JwtSecurityTokenHandler();
                var key = Encoding.UTF8.GetBytes(_configuration["JwtSettings:SecretKey"]!);

                tokenHandler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = true,
                    ValidIssuer = _configuration["JwtSettings:Issuer"],
                    ValidateAudience = true,
                    ValidAudience = _configuration["JwtSettings:Audience"],
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                }, out SecurityToken validatedToken);

                var jwtToken = (JwtSecurityToken)validatedToken;
                var userIdClaim = jwtToken.Claims.First(x => x.Type == ClaimTypes.NameIdentifier).Value;

                return int.Parse(userIdClaim);
            }
            catch
            {
                return null;
            }
        }

        private async Task<UserDto> MapToUserDtoAsync(User user)
        {
            // Eager load related entities if not already loaded
            if (user.AccessType == null && user.AccessLevel.HasValue)
            {
                user.AccessType = await _context.AccessTypes
                    .FirstOrDefaultAsync(at => at.AccessId == user.AccessLevel.Value);
            }

            // Load user modules if not already loaded
            if (user.UserModules == null || !user.UserModules.Any())
            {
                await _context.Entry(user)
                    .Collection(u => u.UserModules)
                    .LoadAsync();
            }

            return new UserDto
            {
                UserId = user.UserId,
                Email = user.Email,
                Name = user.Name,
                Surname = user.Surname,
                PhoneNumber = user.PhoneNumber,
                TimeCreated = user.TimeCreated,
                AccessLevel = user.AccessLevel,
                AccessLevelName = user.AccessType?.Name,
                Degree = user.Degree,
                YearOfStudy = user.YearOfStudy,
                ModuleIds = user.UserModules?.Select(um => um.ModuleId).ToList() ?? new List<int>()
            };
        }

        private int GetJwtExpirationMinutes()
        {
            return int.Parse(_configuration["JwtSettings:ExpirationInMinutes"] ?? "1440");
        }

        private async Task<bool> SendPasswordResetEmailAsync(string email, string userName, string resetCode)
        {
            try
            {
                var subject = "Password Reset - Campus Learn";
                var body = BuildPasswordResetEmailTemplate(userName, resetCode);

                return await _emailService.SendEmailAsync(email, userName, subject, body);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[EMAIL ERROR] Failed to send password reset email: {ex.Message}");
                return false;
            }
        }

        private string BuildPasswordResetEmailTemplate(string userName, string resetCode)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset=""UTF-8"">
    <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"">
    <title>Password Reset - Campus Learn</title>
</head>
<body style=""margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f3f4f6;"">
    <table width=""100%"" cellpadding=""0"" cellspacing=""0"" style=""background-color: #f3f4f6; padding: 20px;"">
        <tr>
            <td align=""center"">
                <table width=""600"" cellpadding=""0"" cellspacing=""0"" style=""background-color: white; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);"">
                    <!-- Header -->
                    <tr>
                        <td style=""background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%); padding: 30px; text-align: center; border-radius: 12px 12px 0 0;"">
                            <h1 style=""color: white; margin: 0; font-size: 28px;"">🎓 Campus Learn</h1>
                        </td>
                    </tr>

                    <!-- Content -->
                    <tr>
                        <td style=""padding: 40px 30px;"">
                            <p style=""color: #6b7280; font-size: 16px; margin: 0 0 10px 0;"">Hi {userName},</p>

                            <p style=""color: #475569; font-size: 15px; line-height: 1.6; margin: 20px 0;"">
                                We received a request to reset your Campus Learn password. Use the code below to reset your password:
                            </p>

                            <div style=""background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%); border-left: 4px solid #2563eb; padding: 30px; margin: 30px 0; border-radius: 8px; text-align: center;"">
                                <div style=""font-size: 48px; margin-bottom: 15px;"">🔐</div>
                                <p style=""color: #1e293b; margin: 0 0 15px 0; font-size: 14px; font-weight: 600; letter-spacing: 1px; text-transform: uppercase;"">
                                    Your Reset Code
                                </p>
                                <div style=""background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); display: inline-block;"">
                                    <p style=""color: #2563eb; margin: 0; font-size: 36px; font-weight: bold; letter-spacing: 8px; font-family: 'Courier New', monospace;"">{resetCode}</p>
                                </div>
                            </div>

                            <div style=""background-color: #fef3c7; border-left: 4px solid #f59e0b; padding: 15px; margin: 20px 0; border-radius: 6px;"">
                                <p style=""color: #92400e; margin: 0; font-size: 14px; line-height: 1.5;"">
                                    ⏱️ <strong>Important:</strong> This code will expire in 15 minutes. If you didn't request this reset, you can safely ignore this email.
                                </p>
                            </div>

                            <div style=""margin-top: 40px; padding-top: 20px; border-top: 1px solid #e5e7eb; color: #6b7280; font-size: 13px;"">
                                <p style=""margin: 5px 0;"">This is an automated email from Campus Learn.</p>
                                <p style=""margin: 5px 0;"">If you have any questions, please contact support.</p>
                            </div>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style=""background-color: #f9fafb; padding: 20px; text-align: center; border-radius: 0 0 12px 12px; color: #9ca3af; font-size: 12px;"">
                            <p style=""margin: 5px 0;"">&copy; {DateTime.Now.Year} Campus Learn. All rights reserved.</p>
                            <p style=""margin: 5px 0;"">Helping students learn together.</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>";
        }
    }
}