using Microsoft.Extensions.Caching.Memory;

namespace CampusLearnBackend.Services
{
    public interface ICacheService
    {
        T? Get<T>(string key);
        void Set<T>(string key, T value, TimeSpan? expiration = null);
        void Remove(string key);
        void RemoveByPrefix(string prefix);
    }

    public class CacheService : ICacheService
    {
        private readonly IMemoryCache _cache;
        private readonly HashSet<string> _cacheKeys = new HashSet<string>();
        private readonly object _lock = new object();

        // Cache key constants
        public static class Keys
        {
            public const string TopicsList = "topics_list";
            public const string Topic = "topic_";
            public const string Comments = "comments_";
            public const string User = "user_";
            public const string TopicLikes = "topic_likes_";
            public const string CommentLikes = "comment_likes_";
        }

        // Cache expiration times
        public static class Expiration
        {
            public static readonly TimeSpan Topics = TimeSpan.FromMinutes(3);
            public static readonly TimeSpan Comments = TimeSpan.FromMinutes(2);
            public static readonly TimeSpan Users = TimeSpan.FromMinutes(5);
            public static readonly TimeSpan Likes = TimeSpan.FromMinutes(1);
        }

        public CacheService(IMemoryCache cache)
        {
            _cache = cache;
        }

        public T? Get<T>(string key)
        {
            return _cache.TryGetValue(key, out T? value) ? value : default;
        }

        public void Set<T>(string key, T value, TimeSpan? expiration = null)
        {
            var cacheEntryOptions = new MemoryCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = expiration ?? TimeSpan.FromMinutes(5),
                SlidingExpiration = TimeSpan.FromMinutes(1) // Refresh if accessed within 1 minute of expiry
            };

            _cache.Set(key, value, cacheEntryOptions);

            // Track cache keys for prefix-based removal
            lock (_lock)
            {
                _cacheKeys.Add(key);
            }
        }

        public void Remove(string key)
        {
            _cache.Remove(key);

            lock (_lock)
            {
                _cacheKeys.Remove(key);
            }
        }

        public void RemoveByPrefix(string prefix)
        {
            lock (_lock)
            {
                var keysToRemove = _cacheKeys.Where(k => k.StartsWith(prefix)).ToList();

                foreach (var key in keysToRemove)
                {
                    _cache.Remove(key);
                    _cacheKeys.Remove(key);
                }
            }
        }
    }
}
