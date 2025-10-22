using Microsoft.AspNetCore.Mvc;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Services;
using CampusLearnBackend.Models;

namespace CampusLearnBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PostsController : ControllerBase
    {
        private readonly IPostService _postService;
        private readonly IAuthService _authService;

        public PostsController(IPostService postService, IAuthService authService)
        {
            _postService = postService;
            _authService = authService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllPosts()
        {
            var userId = GetCurrentUserId();
            var posts = await _postService.GetAllPostsAsync(userId);
            return Ok(posts);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetPost(int id)
        {
            var userId = GetCurrentUserId();
            var post = await _postService.GetPostByIdAsync(id, userId);

            if (post == null)
                return NotFound();

            return Ok(post);
        }

        [HttpGet("{id}/comments")]
        public async Task<IActionResult> GetComments(int id)
        {
            var userId = GetCurrentUserId();
            var comments = await _postService.GetCommentsAsync(id, userId);
            return Ok(comments);
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserPosts(int userId)
        {
            var currentUserId = GetCurrentUserId();
            var posts = await _postService.GetPostsByUserIdAsync(userId, currentUserId);
            return Ok(posts);
        }

        [HttpGet("user/{userId}/comments")]
        public async Task<IActionResult> GetUserComments(int userId)
        {
            var currentUserId = GetCurrentUserId();
            var comments = await _postService.GetCommentsByUserIdAsync(userId, currentUserId);
            return Ok(comments);
        }

        [HttpGet("liked")]
        public async Task<IActionResult> GetLikedPosts()
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var posts = await _postService.GetLikedPostsByUserAsync(userId.Value);
            return Ok(posts);
        }

        [HttpPost]
        public async Task<IActionResult> CreatePost([FromBody] CreatePostDto createPostDto)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Check if user is trying to create a topic
            if (createPostDto.Type == PostTypes.Topic)
            {
                // Only tutors and admins can create topics
                var accessLevel = await _authService.GetAccessLevelAsync(userId.Value);
                if (accessLevel == null || accessLevel < AccessLevels.Tutor)
                {
                    return StatusCode(403, new { message = "Only tutors and admins can create topics" });
                }
            }

            var post = await _postService.CreatePostAsync(createPostDto, userId.Value);

            if (post == null)
                return BadRequest("Failed to create post");

            return CreatedAtAction(nameof(GetPost), new { id = post.PostId }, post);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdatePost(int id, [FromBody] UpdatePostDto updatePostDto)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var post = await _postService.UpdatePostAsync(id, updatePostDto, userId.Value);

            if (post == null)
                return NotFound("Post not found or you don't have permission to update it");

            return Ok(post);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePost(int id)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            // Only admins can delete posts/comments
            var accessLevel = await _authService.GetAccessLevelAsync(userId.Value);
            if (accessLevel == null || accessLevel < AccessLevels.Admin)
            {
                return StatusCode(403, new { message = "Only admins can delete posts and comments" });
            }

            var success = await _postService.DeletePostAsync(id, userId.Value);

            if (!success)
                return NotFound("Post not found");

            return NoContent();
        }

        [HttpPost("{id}/like")]
        public async Task<IActionResult> ToggleLike(int id)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var liked = await _postService.ToggleLikeAsync(id, userId.Value);

            return Ok(new { liked });
        }

        // Helper method to get current user ID from JWT token
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
