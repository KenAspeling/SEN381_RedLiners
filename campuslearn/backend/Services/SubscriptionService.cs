using CampusLearnBackend.Data;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace CampusLearnBackend.Services
{
    public class SubscriptionService : ISubscriptionService
    {
        private readonly CampusLearnContext _context;
        private readonly IMemoryCache _cache;

        public SubscriptionService(CampusLearnContext context, IMemoryCache cache)
        {
            _context = context;
            _cache = cache;
        }

        public async Task<List<SubscriptionDto>> GetUserSubscriptionsAsync(int userId)
        {
            try
            {
                var cacheKey = $"user_subscriptions_{userId}";

                if (_cache.TryGetValue(cacheKey, out List<SubscriptionDto>? cachedSubscriptions) && cachedSubscriptions != null)
                {
                    return cachedSubscriptions;
                }

                var subscriptions = await _context.Subscriptions
                    .Where(s => s.UserId == userId)
                    .OrderByDescending(s => s.TimeCreated)
                    .ToListAsync();

                var subscriptionDtos = subscriptions.Select(s => new SubscriptionDto
                {
                    SubscriptionId = s.SubscriptionId,
                    UserId = s.UserId ?? 0,
                    SubscribableType = s.SubscribableType ?? 0,
                    SubscribableId = s.SubscribableId,
                    TimeCreated = s.TimeCreated
                }).ToList();

                _cache.Set(cacheKey, subscriptionDtos, TimeSpan.FromMinutes(10));

                return subscriptionDtos;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting user subscriptions: {ex.Message}");
                return new List<SubscriptionDto>();
            }
        }

        public async Task<List<SubscriptionDto>> GetUserSubscriptionsByTypeAsync(int userId, int subscribableType)
        {
            try
            {
                var subscriptions = await _context.Subscriptions
                    .Where(s => s.UserId == userId && s.SubscribableType == subscribableType)
                    .OrderByDescending(s => s.TimeCreated)
                    .ToListAsync();

                return subscriptions.Select(s => new SubscriptionDto
                {
                    SubscriptionId = s.SubscriptionId,
                    UserId = s.UserId ?? 0,
                    SubscribableType = s.SubscribableType ?? 0,
                    SubscribableId = s.SubscribableId,
                    TimeCreated = s.TimeCreated
                }).ToList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting subscriptions by type: {ex.Message}");
                return new List<SubscriptionDto>();
            }
        }

        public async Task<bool> IsSubscribedAsync(int userId, int subscribableType, int subscribableId)
        {
            try
            {
                var cacheKey = $"subscription_check_{userId}_{subscribableType}_{subscribableId}";

                if (_cache.TryGetValue(cacheKey, out bool cachedResult))
                {
                    return cachedResult;
                }

                var exists = await _context.Subscriptions
                    .AnyAsync(s => s.UserId == userId
                               && s.SubscribableType == subscribableType
                               && s.SubscribableId == subscribableId);

                _cache.Set(cacheKey, exists, TimeSpan.FromMinutes(5));

                return exists;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error checking subscription: {ex.Message}");
                return false;
            }
        }

        public async Task<SubscriptionDto?> SubscribeAsync(int userId, CreateSubscriptionDto subscriptionDto)
        {
            try
            {
                // Check if already subscribed
                var existingSubscription = await _context.Subscriptions
                    .FirstOrDefaultAsync(s => s.UserId == userId
                                           && s.SubscribableType == subscriptionDto.SubscribableType
                                           && s.SubscribableId == subscriptionDto.SubscribableId);

                if (existingSubscription != null)
                {
                    // Already subscribed, return existing subscription
                    return new SubscriptionDto
                    {
                        SubscriptionId = existingSubscription.SubscriptionId,
                        UserId = existingSubscription.UserId ?? 0,
                        SubscribableType = existingSubscription.SubscribableType ?? 0,
                        SubscribableId = existingSubscription.SubscribableId,
                        TimeCreated = existingSubscription.TimeCreated
                    };
                }

                // Validate subscribable type
                if (subscriptionDto.SubscribableType != 1 && subscriptionDto.SubscribableType != 2)
                {
                    Console.WriteLine("Invalid subscribable type. Must be 1 (Topic) or 2 (Module)");
                    return null;
                }

                // Verify that the topic or module exists
                if (subscriptionDto.SubscribableType == 1) // Topic
                {
                    var topicExists = await _context.Posts.AnyAsync(p => p.PostId == subscriptionDto.SubscribableId);
                    if (!topicExists)
                    {
                        Console.WriteLine($"Topic with ID {subscriptionDto.SubscribableId} does not exist");
                        return null;
                    }
                }
                else if (subscriptionDto.SubscribableType == 2) // Module
                {
                    var moduleExists = await _context.Modules.AnyAsync(m => m.ModuleId == subscriptionDto.SubscribableId);
                    if (!moduleExists)
                    {
                        Console.WriteLine($"Module with ID {subscriptionDto.SubscribableId} does not exist");
                        return null;
                    }
                }

                // Create new subscription
                var subscription = new Subscription
                {
                    UserId = userId,
                    SubscribableType = subscriptionDto.SubscribableType,
                    SubscribableId = subscriptionDto.SubscribableId,
                    TimeCreated = DateTime.UtcNow
                };

                _context.Subscriptions.Add(subscription);
                await _context.SaveChangesAsync();

                // Invalidate cache
                _cache.Remove($"user_subscriptions_{userId}");
                _cache.Remove($"subscription_check_{userId}_{subscriptionDto.SubscribableType}_{subscriptionDto.SubscribableId}");
                _cache.Remove($"subscribers_{subscriptionDto.SubscribableType}_{subscriptionDto.SubscribableId}");

                return new SubscriptionDto
                {
                    SubscriptionId = subscription.SubscriptionId,
                    UserId = subscription.UserId ?? 0,
                    SubscribableType = subscription.SubscribableType ?? 0,
                    SubscribableId = subscription.SubscribableId,
                    TimeCreated = subscription.TimeCreated
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error subscribing: {ex.Message}");
                return null;
            }
        }

        public async Task<bool> UnsubscribeAsync(int userId, int subscribableType, int subscribableId)
        {
            try
            {
                var subscription = await _context.Subscriptions
                    .FirstOrDefaultAsync(s => s.UserId == userId
                                           && s.SubscribableType == subscribableType
                                           && s.SubscribableId == subscribableId);

                if (subscription == null)
                {
                    return false; // Not subscribed
                }

                _context.Subscriptions.Remove(subscription);
                await _context.SaveChangesAsync();

                // Invalidate cache
                _cache.Remove($"user_subscriptions_{userId}");
                _cache.Remove($"subscription_check_{userId}_{subscribableType}_{subscribableId}");
                _cache.Remove($"subscribers_{subscribableType}_{subscribableId}");

                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error unsubscribing: {ex.Message}");
                return false;
            }
        }

        public async Task<List<int>> GetSubscribersAsync(int subscribableType, int subscribableId)
        {
            try
            {
                var cacheKey = $"subscribers_{subscribableType}_{subscribableId}";

                if (_cache.TryGetValue(cacheKey, out List<int>? cachedSubscribers) && cachedSubscribers != null)
                {
                    return cachedSubscribers;
                }

                var subscribers = await _context.Subscriptions
                    .Where(s => s.SubscribableType == subscribableType && s.SubscribableId == subscribableId)
                    .Select(s => s.UserId ?? 0)
                    .Where(id => id != 0)
                    .Distinct()
                    .ToListAsync();

                _cache.Set(cacheKey, subscribers, TimeSpan.FromMinutes(5));

                return subscribers;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting subscribers: {ex.Message}");
                return new List<int>();
            }
        }
    }
}
