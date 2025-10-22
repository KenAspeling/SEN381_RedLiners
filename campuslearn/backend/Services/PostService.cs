using Microsoft.EntityFrameworkCore;
using CampusLearnBackend.Data;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Models;

namespace CampusLearnBackend.Services
{
    public class PostService : IPostService
    {
        private readonly CampusLearnContext _context;
        private readonly ICacheService _cache;
        private readonly ISubscriptionService _subscriptionService;
        private readonly INotificationService _notificationService;

        public PostService(CampusLearnContext context, ICacheService cache, ISubscriptionService subscriptionService, INotificationService notificationService)
        {
            _context = context;
            _cache = cache;
            _subscriptionService = subscriptionService;
            _notificationService = notificationService;
        }

        public async Task<List<PostDto>> GetAllPostsAsync(int? currentUserId = null)
        {
            // Get all posts and topics (type = 1 or 2), exclude comments (type = 0)
            var posts = await _context.Posts
                .Include(p => p.User!)
                    .ThenInclude(u => u.AccessType)
                .Include(p => p.PostType)
                .Include(p => p.ModuleNavigation)
                .Include(p => p.Material)
                .Where(p => p.Type != PostTypes.Comment && p.ParentPostId == null)
                .OrderByDescending(p => p.TimeCreated)
                .ToListAsync();

            var postDtos = new List<PostDto>();
            foreach (var post in posts)
            {
                postDtos.Add(await MapToPostDtoAsync(post, currentUserId));
            }

            return postDtos;
        }

        public async Task<PostDto?> GetPostByIdAsync(int postId, int? currentUserId = null)
        {
            var post = await _context.Posts
                .Include(p => p.User!)
                    .ThenInclude(u => u.AccessType)
                .Include(p => p.PostType)
                .Include(p => p.ModuleNavigation)
                .Include(p => p.Material)
                .FirstOrDefaultAsync(p => p.PostId == postId);

            if (post == null)
                return null;

            return await MapToPostDtoAsync(post, currentUserId);
        }

        public async Task<List<PostDto>> GetPostsByUserIdAsync(int userId, int? currentUserId = null)
        {
            var posts = await _context.Posts
                .Include(p => p.User!)
                    .ThenInclude(u => u.AccessType)
                .Include(p => p.PostType)
                .Include(p => p.ModuleNavigation)
                .Include(p => p.Material)
                .Where(p => p.UserId == userId && p.Type != PostTypes.Comment && p.ParentPostId == null)
                .OrderByDescending(p => p.TimeCreated)
                .ToListAsync();

            var postDtos = new List<PostDto>();
            foreach (var post in posts)
            {
                postDtos.Add(await MapToPostDtoAsync(post, currentUserId));
            }

            return postDtos;
        }

        public async Task<List<PostDto>> GetCommentsByUserIdAsync(int userId, int? currentUserId = null)
        {
            var comments = await _context.Posts
                .Include(p => p.User!)
                    .ThenInclude(u => u.AccessType)
                .Include(p => p.PostType)
                .Include(p => p.ModuleNavigation)
                .Include(p => p.Material)
                .Where(p => p.UserId == userId && p.Type == PostTypes.Comment && p.ParentPostId != null)
                .OrderByDescending(p => p.TimeCreated)
                .ToListAsync();

            var commentDtos = new List<PostDto>();
            foreach (var comment in comments)
            {
                commentDtos.Add(await MapToPostDtoAsync(comment, currentUserId));
            }

            return commentDtos;
        }

        public async Task<PostDto?> CreatePostAsync(CreatePostDto createPostDto, int userId)
        {
            var post = new Post
            {
                UserId = userId,
                ParentPostId = createPostDto.ParentPostId,
                Title = createPostDto.Title,
                Content = createPostDto.Content,
                Type = createPostDto.Type,
                Module = createPostDto.Module,
                MaterialId = createPostDto.MaterialId,
                IsAnonymous = createPostDto.IsAnonymous,
                TimeCreated = DateTime.UtcNow
            };

            _context.Posts.Add(post);
            await _context.SaveChangesAsync();

            // Trigger notifications for subscriptions
            try
            {
                // Case 1: New comment on a topic - notify topic subscribers
                if (post.Type == PostTypes.Comment && post.ParentPostId.HasValue)
                {
                    var subscribers = await _subscriptionService.GetSubscribersAsync(
                        SubscribableTypes.Topic,
                        post.ParentPostId.Value
                    );

                    if (subscribers.Any())
                    {
                        // Filter out the comment author from notifications
                        var subscribersToNotify = subscribers.Where(s => s != userId).ToList();

                        if (subscribersToNotify.Any())
                        {
                            // Get topic title for notification message
                            var topic = await _context.Posts.FindAsync(post.ParentPostId.Value);
                            var topicTitle = topic?.Title ?? "a topic";

                            // Create notification DTOs for all subscribers
                            var notifications = subscribersToNotify.Select(subscriberId => new CreateNotificationDto
                            {
                                UserId = subscriberId,
                                Title = "New comment on subscribed topic",
                                Message = $"New comment on \"{topicTitle}\"",
                                Type = NotificationTypes.Comment,
                                RelatedId = post.ParentPostId.Value
                            }).ToList();

                            // Create all notifications in bulk
                            var count = await _notificationService.CreateBulkNotificationsAsync(notifications);
                            Console.WriteLine($"[SUBSCRIPTION NOTIFICATION] Created {count} notifications for comment on topic {post.ParentPostId.Value}");
                        }
                    }
                }

                // Case 2: New post/topic in a module - notify module subscribers
                if ((post.Type == PostTypes.Post || post.Type == PostTypes.Topic) && post.Module.HasValue)
                {
                    var subscribers = await _subscriptionService.GetSubscribersAsync(
                        SubscribableTypes.Module,
                        post.Module.Value
                    );

                    if (subscribers.Any())
                    {
                        // Filter out the post author from notifications
                        var subscribersToNotify = subscribers.Where(s => s != userId).ToList();

                        if (subscribersToNotify.Any())
                        {
                            // Get module name for notification message
                            var module = await _context.Modules.FindAsync(post.Module.Value);
                            var moduleName = module?.Name ?? "a module";
                            var postType = post.Type == PostTypes.Topic ? "topic" : "post";

                            // Create notification DTOs for all subscribers
                            var notifications = subscribersToNotify.Select(subscriberId => new CreateNotificationDto
                            {
                                UserId = subscriberId,
                                Title = $"New {postType} in {moduleName}",
                                Message = $"\"{post.Title}\"",
                                Type = post.Type == PostTypes.Topic ? NotificationTypes.NewTopic : NotificationTypes.NewPost,
                                RelatedId = post.PostId
                            }).ToList();

                            // Create all notifications in bulk
                            var count = await _notificationService.CreateBulkNotificationsAsync(notifications);
                            Console.WriteLine($"[SUBSCRIPTION NOTIFICATION] Created {count} notifications for new {postType} in module {post.Module.Value}");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error triggering subscription notifications: {ex.Message}");
                // Don't fail the post creation if notification fails
            }

            return await GetPostByIdAsync(post.PostId, userId);
        }

        public async Task<PostDto?> UpdatePostAsync(int postId, UpdatePostDto updatePostDto, int userId)
        {
            var post = await _context.Posts.FirstOrDefaultAsync(p => p.PostId == postId);

            if (post == null || post.UserId != userId)
                return null;

            if (!string.IsNullOrEmpty(updatePostDto.Title))
                post.Title = updatePostDto.Title;

            if (!string.IsNullOrEmpty(updatePostDto.Content))
                post.Content = updatePostDto.Content;

            await _context.SaveChangesAsync();

            return await GetPostByIdAsync(postId, userId);
        }

        public async Task<bool> DeletePostAsync(int postId, int userId)
        {
            var post = await _context.Posts.FirstOrDefaultAsync(p => p.PostId == postId);

            if (post == null)
                return false;

            // Authorization check is done in the controller
            // Only admins can call this method
            _context.Posts.Remove(post);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> ToggleLikeAsync(int postId, int userId)
        {
            // Check if like already exists
            var existingLike = await _context.Likes
                .FirstOrDefaultAsync(l => l.PostId == postId && l.UserId == userId);

            if (existingLike != null)
            {
                // Unlike
                _context.Likes.Remove(existingLike);
            }
            else
            {
                // Like
                var like = new Like
                {
                    PostId = postId,
                    UserId = userId,
                    TimeCreated = DateTime.UtcNow
                };
                _context.Likes.Add(like);
            }

            await _context.SaveChangesAsync();
            return existingLike == null; // Return true if liked, false if unliked
        }

        public async Task<List<PostDto>> GetCommentsAsync(int postId, int? currentUserId = null)
        {
            var comments = await _context.Posts
                .Include(p => p.User!)
                    .ThenInclude(u => u.AccessType)
                .Include(p => p.PostType)
                .Where(p => p.ParentPostId == postId && p.Type == PostTypes.Comment)
                .OrderBy(p => p.TimeCreated)
                .ToListAsync();

            var commentDtos = new List<PostDto>();
            foreach (var comment in comments)
            {
                commentDtos.Add(await MapToPostDtoAsync(comment, currentUserId));
            }

            return commentDtos;
        }

        public async Task<List<PostDto>> GetLikedPostsByUserAsync(int userId)
        {
            // Get all posts/comments that the user has liked
            var likedPostIds = await _context.Likes
                .Where(l => l.UserId == userId)
                .Select(l => l.PostId)
                .ToListAsync();

            var likedPosts = await _context.Posts
                .Include(p => p.User!)
                    .ThenInclude(u => u.AccessType)
                .Include(p => p.PostType)
                .Include(p => p.ModuleNavigation)
                .Include(p => p.Material)
                .Where(p => likedPostIds.Contains(p.PostId))
                .OrderByDescending(p => p.TimeCreated)
                .ToListAsync();

            var postDtos = new List<PostDto>();
            foreach (var post in likedPosts)
            {
                postDtos.Add(await MapToPostDtoAsync(post, userId));
            }

            return postDtos;
        }

        private async Task<PostDto> MapToPostDtoAsync(Post post, int? currentUserId = null)
        {
            // Get like count
            var likeCount = await _context.Likes.CountAsync(l => l.PostId == post.PostId);

            // Get comment count
            var commentCount = await _context.Posts.CountAsync(p => p.ParentPostId == post.PostId && p.Type == PostTypes.Comment);

            // Check if current user liked this post
            var isLikedByCurrentUser = false;
            if (currentUserId.HasValue)
            {
                isLikedByCurrentUser = await _context.Likes
                    .AnyAsync(l => l.PostId == post.PostId && l.UserId == currentUserId.Value);
            }

            // Check if current user is subscribed to this topic
            var isSubscribedByCurrentUser = false;
            if (currentUserId.HasValue)
            {
                isSubscribedByCurrentUser = await _context.Subscriptions
                    .AnyAsync(s => s.SubscribableType == SubscribableTypes.Topic
                        && s.SubscribableId == post.PostId
                        && s.UserId == currentUserId.Value);
            }

            // Construct author name: "Name Surname (Role)" or "Anonymous"
            var authorName = "Anonymous";
            if (!post.IsAnonymous)
            {
                var userName = post.User != null
                    ? $"{post.User.Name} {post.User.Surname}".Trim()
                    : "Unknown";
                var userRole = post.User?.AccessType?.Name ?? "Student";
                authorName = $"{userName} ({userRole})";
            }

            return new PostDto
            {
                PostId = post.PostId,
                UserId = post.IsAnonymous ? null : post.UserId, // Hide userId if anonymous
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
                IsLikedByCurrentUser = isLikedByCurrentUser,
                IsSubscribedByCurrentUser = isSubscribedByCurrentUser,
                IsAnonymous = post.IsAnonymous,
                AuthorName = authorName,
                AuthorEmail = post.IsAnonymous ? "anonymous@campuslearn.com" : (post.User?.Email ?? "unknown@campuslearn.com")
            };
        }
    }
}
