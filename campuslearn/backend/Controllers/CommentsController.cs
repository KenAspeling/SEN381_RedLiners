using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Services;

namespace CampusLearnBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CommentsController : ControllerBase
    {
        private readonly ICommentService _commentService;
        private readonly IAuthService _authService;

        public CommentsController(ICommentService commentService, IAuthService authService)
        {
            _commentService = commentService;
            _authService = authService;
        }

        [HttpGet("topic/{topicId}")]
        public async Task<IActionResult> GetCommentsByTopic(int topicId)
        {
            var userId = GetCurrentUserId();
            var comments = await _commentService.GetCommentsByTopicAsync(topicId, userId);
            return Ok(comments);
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetCommentsByUser(int userId)
        {
            var currentUserId = GetCurrentUserId();
            var comments = await _commentService.GetCommentsByUserAsync(userId, currentUserId);
            return Ok(comments);
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreateComment([FromBody] CreateCommentDto createCommentDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var comment = await _commentService.CreateCommentAsync(createCommentDto, userId.Value);
            return CreatedAtAction(nameof(GetCommentsByTopic), new { topicId = comment.TopicId }, comment);
        }

        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> UpdateComment(int id, [FromBody] UpdateCommentDto updateCommentDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var comment = await _commentService.UpdateCommentAsync(id, updateCommentDto, userId.Value);
            if (comment == null)
                return NotFound();

            return Ok(comment);
        }

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> DeleteComment(int id)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var success = await _commentService.DeleteCommentAsync(id, userId.Value);
            if (!success)
                return NotFound();

            return NoContent();
        }

        [HttpPost("{id}/like")]
        [Authorize]
        public async Task<IActionResult> ToggleLike(int id)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var isLiked = await _commentService.ToggleLikeAsync(id, userId.Value);
            return Ok(new { isLiked });
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