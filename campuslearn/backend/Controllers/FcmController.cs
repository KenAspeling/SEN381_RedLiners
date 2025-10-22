using Microsoft.AspNetCore.Mvc;
using CampusLearnBackend.Data;
using CampusLearnBackend.Services;
using CampusLearnBackend.Models;
using Microsoft.EntityFrameworkCore;

namespace CampusLearnBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FcmController : ControllerBase
    {
        private readonly CampusLearnContext _context;
        private readonly IAuthService _authService;

        public FcmController(CampusLearnContext context, IAuthService authService)
        {
            _context = context;
            _authService = authService;
        }

        // Helper method to get user ID from token
        private int? GetUserIdFromToken()
        {
            var authHeader = Request.Headers["Authorization"].FirstOrDefault();
            if (authHeader == null || !authHeader.StartsWith("Bearer "))
                return null;

            var token = authHeader.Substring("Bearer ".Length).Trim();
            return _authService.GetUserIdFromToken(token);
        }

        // POST: api/fcm/token
        // Save or update FCM token for current user
        [HttpPost("token")]
        public async Task<IActionResult> SaveToken([FromBody] SaveFcmTokenRequest request)
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            try
            {
                // Check if token already exists
                var existingToken = await _context.FcmTokens
                    .FirstOrDefaultAsync(t => t.Token == request.FcmToken);

                if (existingToken != null)
                {
                    // Update existing token
                    existingToken.UserId = userId.Value;
                    existingToken.DeviceType = request.DeviceType ?? "android";
                    existingToken.DeviceInfo = request.DeviceInfo;
                    existingToken.IsActive = true;
                    existingToken.TimeUpdated = DateTime.UtcNow;
                }
                else
                {
                    // Create new token
                    var fcmToken = new FcmToken
                    {
                        UserId = userId.Value,
                        Token = request.FcmToken,
                        DeviceType = request.DeviceType ?? "android",
                        DeviceInfo = request.DeviceInfo,
                        IsActive = true,
                        TimeCreated = DateTime.UtcNow,
                        TimeUpdated = DateTime.UtcNow
                    };

                    _context.FcmTokens.Add(fcmToken);
                }

                await _context.SaveChangesAsync();

                Console.WriteLine($"[FCM] Saved token for user {userId}");
                return Ok(new { message = "Token saved successfully" });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[FCM ERROR] Failed to save token: {ex.Message}");
                return StatusCode(500, new { message = "Failed to save token" });
            }
        }

        // DELETE: api/fcm/token
        // Delete FCM token (on logout)
        [HttpDelete("token")]
        public async Task<IActionResult> DeleteToken([FromBody] DeleteFcmTokenRequest request)
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            try
            {
                var token = await _context.FcmTokens
                    .FirstOrDefaultAsync(t => t.Token == request.FcmToken && t.UserId == userId.Value);

                if (token != null)
                {
                    // Mark as inactive instead of deleting (keeps history)
                    token.IsActive = false;
                    token.TimeUpdated = DateTime.UtcNow;
                    await _context.SaveChangesAsync();

                    Console.WriteLine($"[FCM] Deactivated token for user {userId}");
                    return Ok(new { message = "Token deleted successfully" });
                }

                return NotFound(new { message = "Token not found" });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[FCM ERROR] Failed to delete token: {ex.Message}");
                return StatusCode(500, new { message = "Failed to delete token" });
            }
        }

        // GET: api/fcm/tokens
        // Get all active tokens for current user (for debugging)
        [HttpGet("tokens")]
        public async Task<IActionResult> GetUserTokens()
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            try
            {
                var tokens = await _context.FcmTokens
                    .Where(t => t.UserId == userId.Value && t.IsActive)
                    .Select(t => new
                    {
                        t.TokenId,
                        t.DeviceType,
                        t.DeviceInfo,
                        t.TimeCreated,
                        t.TimeUpdated
                    })
                    .ToListAsync();

                return Ok(tokens);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[FCM ERROR] Failed to get tokens: {ex.Message}");
                return StatusCode(500, new { message = "Failed to get tokens" });
            }
        }
    }

    // Request models
    public class SaveFcmTokenRequest
    {
        public string FcmToken { get; set; } = string.Empty;
        public string? DeviceType { get; set; }
        public string? DeviceInfo { get; set; }
    }

    public class DeleteFcmTokenRequest
    {
        public string FcmToken { get; set; } = string.Empty;
    }
}
