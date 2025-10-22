using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CampusLearnBackend.Data;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Models;

namespace CampusLearnBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ModulesController : ControllerBase
    {
        private readonly CampusLearnContext _context;

        public ModulesController(CampusLearnContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Get all modules or filter by IDs
        /// GET /api/modules
        /// GET /api/modules?ids=1,2,3
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ModuleDto>>> GetModules([FromQuery] string? ids)
        {
            try
            {
                IQueryable<Models.Module> query = _context.Modules;

                // Filter by IDs if provided
                if (!string.IsNullOrEmpty(ids))
                {
                    var idList = ids.Split(',')
                        .Select(id => int.TryParse(id.Trim(), out var result) ? result : 0)
                        .Where(id => id > 0)
                        .ToList();

                    if (idList.Any())
                    {
                        query = query.Where(m => idList.Contains(m.ModuleId));
                    }
                }

                var modules = await query
                    .OrderBy(m => m.Tag)
                    .ToListAsync();

                var moduleDtos = modules.Select(m => new ModuleDto
                {
                    ModuleId = m.ModuleId,
                    Name = m.Name,
                    Tag = m.Tag,
                    Description = m.Description
                }).ToList();

                return Ok(moduleDtos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error fetching modules", error = ex.Message });
            }
        }

        /// <summary>
        /// Get a single module by ID
        /// GET /api/modules/5
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<ModuleDto>> GetModule(int id)
        {
            try
            {
                var module = await _context.Modules
                    .FirstOrDefaultAsync(m => m.ModuleId == id);

                if (module == null)
                {
                    return NotFound(new { message = $"Module with ID {id} not found" });
                }

                var moduleDto = new ModuleDto
                {
                    ModuleId = module.ModuleId,
                    Name = module.Name,
                    Tag = module.Tag,
                    Description = module.Description
                };

                return Ok(moduleDto);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error fetching module", error = ex.Message });
            }
        }

        /// <summary>
        /// Get modules for the authenticated user
        /// GET /api/modules/my-modules
        /// </summary>
        [HttpGet("my-modules")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<ModuleDto>>> GetMyModules()
        {
            try
            {
                // Get user ID from JWT token claims
                var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
                if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out var userId))
                {
                    return Unauthorized(new { message = "Invalid token" });
                }

                // Get user's modules through the user_module junction table
                var userModules = await _context.UserModules
                    .Where(um => um.UserId == userId)
                    .Include(um => um.Module)
                    .Select(um => um.Module)
                    .OrderBy(m => m.Tag)
                    .ToListAsync();

                var moduleDtos = userModules.Select(m => new ModuleDto
                {
                    ModuleId = m.ModuleId,
                    Name = m.Name,
                    Tag = m.Tag,
                    Description = m.Description
                }).ToList();

                return Ok(moduleDtos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error fetching user modules", error = ex.Message });
            }
        }

        /// <summary>
        /// Get posts for a specific module
        /// GET /api/modules/5/posts
        /// </summary>
        [HttpGet("{id}/posts")]
        public async Task<ActionResult<IEnumerable<PostDto>>> GetModulePosts(int id)
        {
            try
            {
                // Check if module exists
                var moduleExists = await _context.Modules.AnyAsync(m => m.ModuleId == id);
                if (!moduleExists)
                {
                    return NotFound(new { message = $"Module with ID {id} not found" });
                }

                // Get posts for this module (topics and posts only, no comments)
                var posts = await _context.Posts
                    .Include(p => p.User!)
                        .ThenInclude(u => u.AccessType)
                    .Include(p => p.PostType)
                    .Include(p => p.ModuleNavigation)
                    .Include(p => p.Material)
                    .Where(p => p.Module == id && p.ParentPostId == null && p.Type != PostTypes.Comment)
                    .OrderByDescending(p => p.TimeCreated)
                    .ToListAsync();

                var postDtos = new List<PostDto>();
                foreach (var post in posts)
                {
                    var likeCount = await _context.Likes.CountAsync(l => l.PostId == post.PostId);
                    var commentCount = await _context.Posts.CountAsync(p => p.ParentPostId == post.PostId && p.Type == PostTypes.Comment);

                    postDtos.Add(new PostDto
                    {
                        PostId = post.PostId,
                        UserId = post.UserId,
                        ParentPostId = post.ParentPostId,
                        Title = post.Title,
                        Content = post.Content,
                        Type = post.Type,
                        TypeName = post.PostType?.Name,
                        Module = post.Module,
                        ModuleName = post.ModuleNavigation?.Name,
                        TimeCreated = post.TimeCreated,
                        MaterialId = post.MaterialId,
                        MaterialTitle = post.Material?.Title,
                        LikeCount = likeCount,
                        CommentCount = commentCount,
                        IsLikedByCurrentUser = false,
                        IsSubscribedByCurrentUser = false,
                        AuthorName = post.User?.AccessType?.Name ?? "student",
                        AuthorEmail = post.User?.Email ?? "unknown@campuslearn.com"
                    });
                }

                return Ok(postDtos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error fetching module posts", error = ex.Message });
            }
        }

        /// <summary>
        /// Enroll a user in multiple modules
        /// POST /api/modules/enroll
        /// </summary>
        [HttpPost("enroll")]
        [Authorize]
        public async Task<IActionResult> EnrollInModules([FromBody] EnrollModulesDto enrollDto)
        {
            try
            {
                // Get user ID from JWT token claims
                var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
                if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out var userId))
                {
                    return Unauthorized(new { message = "Invalid token" });
                }

                // Verify user exists
                var userExists = await _context.Users.AnyAsync(u => u.UserId == userId);
                if (!userExists)
                {
                    return NotFound(new { message = "User not found" });
                }

                // Get existing enrollments for this user
                var existingEnrollments = await _context.UserModules
                    .Where(um => um.UserId == userId)
                    .Select(um => um.ModuleId)
                    .ToListAsync();

                // Determine which modules to add and which to remove
                var modulesToAdd = enrollDto.ModuleIds.Except(existingEnrollments).ToList();
                var modulesToRemove = existingEnrollments.Except(enrollDto.ModuleIds).ToList();

                // Remove modules that are no longer selected
                if (modulesToRemove.Any())
                {
                    var enrollmentsToRemove = await _context.UserModules
                        .Where(um => um.UserId == userId && modulesToRemove.Contains(um.ModuleId))
                        .ToListAsync();
                    _context.UserModules.RemoveRange(enrollmentsToRemove);
                }

                // Add new module enrollments
                foreach (var moduleId in modulesToAdd)
                {
                    // Verify module exists
                    var moduleExists = await _context.Modules.AnyAsync(m => m.ModuleId == moduleId);
                    if (!moduleExists)
                    {
                        return BadRequest(new { message = $"Module with ID {moduleId} not found" });
                    }

                    _context.UserModules.Add(new UserModule
                    {
                        UserId = userId,
                        ModuleId = moduleId
                    });
                }

                await _context.SaveChangesAsync();

                return Ok(new { message = "Module enrollments updated successfully", enrolledModules = enrollDto.ModuleIds.Count });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error enrolling in modules", error = ex.Message });
            }
        }
    }
}
