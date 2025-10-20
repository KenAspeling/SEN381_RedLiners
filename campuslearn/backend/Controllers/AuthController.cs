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
    }
}