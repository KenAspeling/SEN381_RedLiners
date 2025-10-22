using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using CampusLearnBackend.Data;
using CampusLearnBackend.Services;

namespace CampusLearnBackend.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class SearchController : ControllerBase
    {
        private readonly CampusLearnContext _context;
        private readonly IAuthService _authService;

        public SearchController(CampusLearnContext context, IAuthService authService)
        {
            _context = context;
            _authService = authService;
        }

        /// <summary>
        /// Search across users, posts, and modules
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> Search([FromQuery] string query, [FromQuery] string? type = null)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            if (string.IsNullOrWhiteSpace(query) || query.Length < 2)
                return Ok(new { users = new List<object>(), posts = new List<object>(), modules = new List<object>() });

            var searchTerm = query.ToLower();

            var results = new
            {
                users = type == null || type == "users" ? await SearchUsers(searchTerm) : new List<object>(),
                posts = type == null || type == "posts" ? await SearchPosts(searchTerm) : new List<object>(),
                modules = type == null || type == "modules" ? await SearchModules(searchTerm) : new List<object>()
            };

            return Ok(results);
        }

        private async Task<List<object>> SearchUsers(string searchTerm)
        {
            var users = await _context.Users
                .Include(u => u.AccessType)
                .Where(u =>
                    u.Name.ToLower().Contains(searchTerm) ||
                    u.Surname.ToLower().Contains(searchTerm) ||
                    u.Email.ToLower().Contains(searchTerm) ||
                    (u.Name + " " + u.Surname).ToLower().Contains(searchTerm))
                .Take(20)
                .Select(u => new
                {
                    type = "user",
                    userId = u.UserId,
                    name = u.Name + " " + u.Surname,
                    email = u.Email,
                    accessLevelName = u.AccessType != null ? u.AccessType.Name : "Student"
                })
                .ToListAsync();

            return users.Cast<object>().ToList();
        }

        private async Task<List<object>> SearchPosts(string searchTerm)
        {
            var posts = await _context.Posts
                .Include(p => p.User)
                .Include(p => p.PostType)
                .Where(p =>
                    p.ParentPostId == null && // Only topics, not comments
                    (p.Title.ToLower().Contains(searchTerm) ||
                     p.Content.ToLower().Contains(searchTerm)))
                .OrderByDescending(p => p.TimeCreated)
                .Take(20)
                .Select(p => new
                {
                    type = "post",
                    postId = p.PostId,
                    title = p.Title,
                    content = p.Content.Length > 100 ? p.Content.Substring(0, 100) + "..." : p.Content,
                    author = p.User != null ? p.User.Name + " " + p.User.Surname : "Unknown",
                    authorEmail = p.User != null ? p.User.Email : "",
                    timeCreated = p.TimeCreated,
                    typeName = p.PostType != null ? p.PostType.Name : "Post"
                })
                .ToListAsync();

            return posts.Cast<object>().ToList();
        }

        private async Task<List<object>> SearchModules(string searchTerm)
        {
            var modules = await _context.Modules
                .Where(m =>
                    m.Name.ToLower().Contains(searchTerm) ||
                    (m.Tag != null && m.Tag.ToLower().Contains(searchTerm)))
                .Take(20)
                .Select(m => new
                {
                    type = "module",
                    moduleId = m.ModuleId,
                    name = m.Name,
                    tag = m.Tag
                })
                .ToListAsync();

            return modules.Cast<object>().ToList();
        }

        private int? GetCurrentUserId()
        {
            var authHeader = Request.Headers["Authorization"].FirstOrDefault();
            if (authHeader == null || !authHeader.StartsWith("Bearer "))
                return null;

            var token = authHeader.Substring("Bearer ".Length).Trim();
            return _authService.GetUserIdFromToken(token);
        }
    }
}
