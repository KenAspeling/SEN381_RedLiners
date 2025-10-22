using Microsoft.AspNetCore.Mvc;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Services;

namespace CampusLearnBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SubscriptionsController : ControllerBase
    {
        private readonly ISubscriptionService _subscriptionService;
        private readonly IAuthService _authService;

        public SubscriptionsController(ISubscriptionService subscriptionService, IAuthService authService)
        {
            _subscriptionService = subscriptionService;
            _authService = authService;
        }

        // Get user ID from token helper method
        private int? GetUserIdFromToken()
        {
            var authHeader = Request.Headers["Authorization"].FirstOrDefault();
            if (authHeader == null || !authHeader.StartsWith("Bearer "))
                return null;

            var token = authHeader.Substring("Bearer ".Length).Trim();
            return _authService.GetUserIdFromToken(token);
        }

        // GET: api/subscriptions
        // Get all subscriptions for the authenticated user
        [HttpGet]
        public async Task<IActionResult> GetUserSubscriptions()
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            var subscriptions = await _subscriptionService.GetUserSubscriptionsAsync(userId.Value);
            return Ok(subscriptions);
        }

        // GET: api/subscriptions/type/{subscribableType}
        // Get subscriptions by type (1=Topic, 2=Module)
        [HttpGet("type/{subscribableType}")]
        public async Task<IActionResult> GetUserSubscriptionsByType(int subscribableType)
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            if (subscribableType != 1 && subscribableType != 2)
                return BadRequest(new { message = "Subscribable type must be 1 (Topic) or 2 (Module)" });

            var subscriptions = await _subscriptionService.GetUserSubscriptionsByTypeAsync(userId.Value, subscribableType);
            return Ok(subscriptions);
        }

        // GET: api/subscriptions/check/{subscribableType}/{subscribableId}
        // Check if user is subscribed to a specific item
        [HttpGet("check/{subscribableType}/{subscribableId}")]
        public async Task<IActionResult> CheckSubscription(int subscribableType, int subscribableId)
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            if (subscribableType != 1 && subscribableType != 2)
                return BadRequest(new { message = "Subscribable type must be 1 (Topic) or 2 (Module)" });

            var isSubscribed = await _subscriptionService.IsSubscribedAsync(userId.Value, subscribableType, subscribableId);
            return Ok(new { isSubscribed });
        }

        // POST: api/subscriptions
        // Subscribe to a topic or module
        [HttpPost]
        public async Task<IActionResult> Subscribe([FromBody] CreateSubscriptionDto subscriptionDto)
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (subscriptionDto.SubscribableType != 1 && subscriptionDto.SubscribableType != 2)
                return BadRequest(new { message = "Subscribable type must be 1 (Topic) or 2 (Module)" });

            var subscription = await _subscriptionService.SubscribeAsync(userId.Value, subscriptionDto);

            if (subscription == null)
                return BadRequest(new { message = "Failed to create subscription. Item may not exist." });

            return Ok(subscription);
        }

        // DELETE: api/subscriptions/{subscribableType}/{subscribableId}
        // Unsubscribe from a topic or module
        [HttpDelete("{subscribableType}/{subscribableId}")]
        public async Task<IActionResult> Unsubscribe(int subscribableType, int subscribableId)
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            if (subscribableType != 1 && subscribableType != 2)
                return BadRequest(new { message = "Subscribable type must be 1 (Topic) or 2 (Module)" });

            var success = await _subscriptionService.UnsubscribeAsync(userId.Value, subscribableType, subscribableId);

            if (!success)
                return NotFound(new { message = "Subscription not found" });

            return Ok(new { message = "Successfully unsubscribed" });
        }

        // GET: api/subscriptions/subscribers/{subscribableType}/{subscribableId}
        // Get all subscribers for a specific item (for admin/notification purposes)
        [HttpGet("subscribers/{subscribableType}/{subscribableId}")]
        public async Task<IActionResult> GetSubscribers(int subscribableType, int subscribableId)
        {
            var userId = GetUserIdFromToken();
            if (userId == null)
                return Unauthorized();

            if (subscribableType != 1 && subscribableType != 2)
                return BadRequest(new { message = "Subscribable type must be 1 (Topic) or 2 (Module)" });

            var subscribers = await _subscriptionService.GetSubscribersAsync(subscribableType, subscribableId);
            return Ok(new { count = subscribers.Count, subscribers });
        }
    }
}
