using CampusLearnBackend.DTOs;

namespace CampusLearnBackend.Services
{
    public interface ISubscriptionService
    {
        // Get all subscriptions for a user
        Task<List<SubscriptionDto>> GetUserSubscriptionsAsync(int userId);

        // Get subscriptions by type (1=Topic, 2=Module)
        Task<List<SubscriptionDto>> GetUserSubscriptionsByTypeAsync(int userId, int subscribableType);

        // Check if user is subscribed to a specific item
        Task<bool> IsSubscribedAsync(int userId, int subscribableType, int subscribableId);

        // Subscribe to a topic or module
        Task<SubscriptionDto?> SubscribeAsync(int userId, CreateSubscriptionDto subscriptionDto);

        // Unsubscribe from a topic or module
        Task<bool> UnsubscribeAsync(int userId, int subscribableType, int subscribableId);

        // Get all users subscribed to a specific topic (for notifications)
        Task<List<int>> GetSubscribersAsync(int subscribableType, int subscribableId);
    }
}
