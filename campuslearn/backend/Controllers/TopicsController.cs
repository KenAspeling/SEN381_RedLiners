using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Services;

namespace CampusLearnBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TopicsController : ControllerBase
    {
        private readonly ITopicService _topicService;
        private readonly IAuthService _authService;

        public TopicsController(ITopicService topicService, IAuthService authService)
        {
            _topicService = topicService;
            _authService = authService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllTopics()
        {
            var userId = GetCurrentUserId();
            var topics = await _topicService.GetAllTopicsAsync(userId);
            return Ok(topics);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetTopicById(int id)
        {
            var userId = GetCurrentUserId();
            var topic = await _topicService.GetTopicByIdAsync(id, userId);
            
            if (topic == null)
                return NotFound();

            // Increment view count
            await _topicService.IncrementViewCountAsync(id);

            return Ok(topic);
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetTopicsByUser(int userId)
        {
            var currentUserId = GetCurrentUserId();
            var topics = await _topicService.GetTopicsByUserAsync(userId, currentUserId);
            return Ok(topics);
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreateTopic([FromBody] CreateTopicDto createTopicDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var topic = await _topicService.CreateTopicAsync(createTopicDto, userId.Value);
            return CreatedAtAction(nameof(GetTopicById), new { id = topic.Id }, topic);
        }

        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> UpdateTopic(int id, [FromBody] UpdateTopicDto updateTopicDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var topic = await _topicService.UpdateTopicAsync(id, updateTopicDto, userId.Value);
            if (topic == null)
                return NotFound();

            return Ok(topic);
        }

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> DeleteTopic(int id)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var success = await _topicService.DeleteTopicAsync(id, userId.Value);
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

            var isLiked = await _topicService.ToggleLikeAsync(id, userId.Value);
            return Ok(new { isLiked });
        }

        [HttpGet("search")]
        public async Task<IActionResult> SearchTopics([FromQuery] string query)
        {
            if (string.IsNullOrWhiteSpace(query))
                return BadRequest("Query parameter is required");

            var userId = GetCurrentUserId();
            var topics = await _topicService.SearchTopicsAsync(query, userId);
            return Ok(topics);
        }

        [HttpGet("trending")]
        public async Task<IActionResult> GetTrendingTopics()
        {
            var userId = GetCurrentUserId();
            var topics = await _topicService.GetTrendingTopicsAsync(userId);
            return Ok(topics);
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