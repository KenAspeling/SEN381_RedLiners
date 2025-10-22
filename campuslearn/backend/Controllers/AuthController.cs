using Microsoft.AspNetCore.Mvc;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Services;

namespace CampusLearnBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto registerDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _authService.RegisterAsync(registerDto);
            if (result == null)
                return BadRequest("User with this email already exists");

            return Ok(result);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto loginDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _authService.LoginAsync(loginDto);
            if (result == null)
                return Unauthorized("Invalid email or password");

            return Ok(result);
        }

        [HttpGet("me")]
        public async Task<IActionResult> GetCurrentUser()
        {
            var authHeader = Request.Headers["Authorization"].FirstOrDefault();
            if (authHeader == null || !authHeader.StartsWith("Bearer "))
                return Unauthorized();

            var token = authHeader.Substring("Bearer ".Length).Trim();
            var userId = _authService.GetUserIdFromToken(token);

            if (userId == null)
                return Unauthorized();

            var user = await _authService.GetUserByIdAsync(userId.Value);
            if (user == null)
                return NotFound();

            return Ok(user);
        }

        [HttpGet("check-tutor")]
        public async Task<IActionResult> CheckTutorStatus()
        {
            var authHeader = Request.Headers["Authorization"].FirstOrDefault();
            if (authHeader == null || !authHeader.StartsWith("Bearer "))
                return Unauthorized();

            var token = authHeader.Substring("Bearer ".Length).Trim();
            var userId = _authService.GetUserIdFromToken(token);

            if (userId == null)
                return Unauthorized();

            var isTutor = await _authService.IsTutorAsync(userId.Value);
            return Ok(new { isTutor });
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserById(int userId)
        {
            var user = await _authService.GetUserByIdAsync(userId);
            if (user == null)
                return NotFound(new { message = "User not found" });

            return Ok(user);
        }

        [HttpGet("access-level")]
        public async Task<IActionResult> GetAccessLevel()
        {
            var authHeader = Request.Headers["Authorization"].FirstOrDefault();
            if (authHeader == null || !authHeader.StartsWith("Bearer "))
                return Unauthorized();

            var token = authHeader.Substring("Bearer ".Length).Trim();
            var userId = _authService.GetUserIdFromToken(token);

            if (userId == null)
                return Unauthorized();

            var accessLevel = await _authService.GetAccessLevelAsync(userId.Value);
            return Ok(new { accessLevel, userId });
        }

        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDto updateDto)
        {
            var authHeader = Request.Headers["Authorization"].FirstOrDefault();
            if (authHeader == null || !authHeader.StartsWith("Bearer "))
                return Unauthorized();

            var token = authHeader.Substring("Bearer ".Length).Trim();
            var userId = _authService.GetUserIdFromToken(token);

            if (userId == null)
                return Unauthorized();

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var updatedUser = await _authService.UpdateProfileAsync(userId.Value, updateDto);
            if (updatedUser == null)
                return NotFound(new { message = "User not found" });

            return Ok(updatedUser);
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto forgotPasswordDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _authService.RequestPasswordResetAsync(forgotPasswordDto.Email);

            // Always return success to prevent email enumeration
            return Ok(new { message = "If an account with that email exists, a reset code has been sent." });
        }

        [HttpPost("verify-reset-code")]
        public async Task<IActionResult> VerifyResetCode([FromBody] VerifyResetCodeDto verifyDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var isValid = await _authService.VerifyResetCodeAsync(verifyDto.Email, verifyDto.Code);

            if (!isValid)
                return BadRequest(new { message = "Invalid or expired code" });

            return Ok(new { message = "Code verified successfully" });
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto resetDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _authService.ResetPasswordAsync(resetDto.Email, resetDto.Code, resetDto.NewPassword);

            if (!result)
                return BadRequest(new { message = "Failed to reset password. Code may be invalid or expired." });

            return Ok(new { message = "Password reset successfully" });
        }
    }
}