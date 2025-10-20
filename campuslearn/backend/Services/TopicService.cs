using Microsoft.EntityFrameworkCore;
using CampusLearnBackend.Data;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Models;

namespace CampusLearnBackend.Services
{
    public class TopicService : ITopicService
    {
        private readonly CampusLearnContext _context;

        public TopicService(CampusLearnContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<TopicDto>> GetAllTopicsAsync(int? userId = null)
        {
            var topics = await _context.Topics
                .Include(t => t.User)
                .Include(t => t.TopicLikes)
                .Include(t => t.Comments)
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();

            return topics.Select(t => MapToDto(t, userId));
        }

        public async Task<TopicDto?> GetTopicByIdAsync(int id, int? userId = null)
        {
            var topic = await _context.Topics
                .Include(t => t.User)
                .Include(t => t.TopicLikes)
                .Include(t => t.Comments)
                .FirstOrDefaultAsync(t => t.Id == id);

            return topic != null ? MapToDto(topic, userId) : null;
        }

        public async Task<IEnumerable<TopicDto>> GetTopicsByUserAsync(int userId, int? currentUserId = null)
        {
            var topics = await _context.Topics
                .Include(t => t.User)
                .Include(t => t.TopicLikes)
                .Include(t => t.Comments)
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();

            return topics.Select(t => MapToDto(t, currentUserId));
        }

        public async Task<TopicDto> CreateTopicAsync(CreateTopicDto createTopicDto, int userId)
        {
            var topic = new Topic
            {
                Title = createTopicDto.Title,
                Content = createTopicDto.Content,
                UserId = userId
                // IsAnnouncement removed - column doesn't exist in database
            };

            _context.Topics.Add(topic);
            await _context.SaveChangesAsync();

            // Reload with includes
            await _context.Entry(topic)
                .Reference(t => t.User)
                .LoadAsync();

            return MapToDto(topic, userId);
        }

        public async Task<TopicDto?> UpdateTopicAsync(int id, UpdateTopicDto updateTopicDto, int userId)
        {
            var topic = await _context.Topics
                .Include(t => t.User)
                .Include(t => t.TopicLikes)
                .Include(t => t.Comments)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (topic == null || topic.UserId != userId)
                return null;

            if (!string.IsNullOrEmpty(updateTopicDto.Title))
                topic.Title = updateTopicDto.Title;

            if (!string.IsNullOrEmpty(updateTopicDto.Content))
                topic.Content = updateTopicDto.Content;

            // IsAnnouncement update removed - column doesn't exist in database

            await _context.SaveChangesAsync();
            return MapToDto(topic, userId);
        }

        public async Task<bool> DeleteTopicAsync(int id, int userId)
        {
            var topic = await _context.Topics.FirstOrDefaultAsync(t => t.Id == id);

            if (topic == null || topic.UserId != userId)
                return false;

            _context.Topics.Remove(topic);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> ToggleLikeAsync(int topicId, int userId)
        {
            var existingLike = await _context.TopicLikes
                .FirstOrDefaultAsync(tl => tl.TopicId == topicId && tl.UserId == userId);

            if (existingLike != null)
            {
                _context.TopicLikes.Remove(existingLike);
            }
            else
            {
                var like = new TopicLike
                {
                    TopicId = topicId,
                    UserId = userId
                };
                _context.TopicLikes.Add(like);
            }

            await _context.SaveChangesAsync();
            return existingLike == null; // Return true if liked, false if unliked
        }

        public async Task<bool> IncrementViewCountAsync(int topicId)
        {
            var topic = await _context.Topics.FirstOrDefaultAsync(t => t.Id == topicId);
            if (topic == null)
                return false;

            topic.ViewCount++;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<TopicDto>> SearchTopicsAsync(string query, int? userId = null)
        {
            var topics = await _context.Topics
                .Include(t => t.User)
                .Include(t => t.TopicLikes)
                .Include(t => t.Comments)
                .Where(t => t.Title.Contains(query) || t.Content.Contains(query) || t.User.Name.Contains(query))
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();

            return topics.Select(t => MapToDto(t, userId));
        }

        public async Task<IEnumerable<TopicDto>> GetTrendingTopicsAsync(int? userId = null)
        {
            var weekAgo = DateTime.UtcNow.AddDays(-7);
            var topics = await _context.Topics
                .Include(t => t.User)
                .Include(t => t.TopicLikes)
                .Include(t => t.Comments)
                .Where(t => t.CreatedAt >= weekAgo)
                .ToListAsync();

            return topics
                .OrderByDescending(t => t.LikeCount + t.CommentCount)
                .Take(10)
                .Select(t => MapToDto(t, userId));
        }

        private TopicDto MapToDto(Topic topic, int? userId = null)
        {
            return new TopicDto
            {
                Id = topic.Id,
                Title = topic.Title,
                Content = topic.Content,
                AuthorName = topic.AuthorName,
                AuthorEmail = topic.AuthorEmail,
                CreatedAt = topic.CreatedAt,
                UpdatedAt = topic.UpdatedAt,
                LikeCount = topic.LikeCount,
                CommentCount = topic.CommentCount,
                ViewCount = topic.ViewCount,
                IsLiked = userId.HasValue && topic.TopicLikes.Any(tl => tl.UserId == userId.Value)
                // IsAnnouncement removed - column doesn't exist in database
            };
        }
    }
}