using Microsoft.EntityFrameworkCore;
using CampusLearnBackend.Data;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Models;

namespace CampusLearnBackend.Services
{
    public class CommentService : ICommentService
    {
        private readonly CampusLearnContext _context;

        public CommentService(CampusLearnContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<CommentDto>> GetCommentsByTopicAsync(int topicId, int? userId = null)
        {
            var comments = await _context.Comments
                .Include(c => c.User)
                .Include(c => c.CommentLikes)
                .Where(c => c.TopicId == topicId)
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();

            return comments.Select(c => MapToDto(c, userId));
        }

        public async Task<IEnumerable<CommentDto>> GetCommentsByUserAsync(int userId, int? currentUserId = null)
        {
            var comments = await _context.Comments
                .Include(c => c.User)
                .Include(c => c.CommentLikes)
                .Where(c => c.UserId == userId)
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();

            return comments.Select(c => MapToDto(c, currentUserId));
        }

        public async Task<CommentDto> CreateCommentAsync(CreateCommentDto createCommentDto, int userId)
        {
            var comment = new Comment
            {
                TopicId = createCommentDto.TopicId,
                Content = createCommentDto.Content,
                UserId = userId
            };

            _context.Comments.Add(comment);
            await _context.SaveChangesAsync();

            // Reload with includes
            await _context.Entry(comment)
                .Reference(c => c.User)
                .LoadAsync();

            return MapToDto(comment, userId);
        }

        public async Task<CommentDto?> UpdateCommentAsync(int id, UpdateCommentDto updateCommentDto, int userId)
        {
            var comment = await _context.Comments
                .Include(c => c.User)
                .Include(c => c.CommentLikes)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (comment == null || comment.UserId != userId)
                return null;

            comment.Content = updateCommentDto.Content;
            await _context.SaveChangesAsync();

            return MapToDto(comment, userId);
        }

        public async Task<bool> DeleteCommentAsync(int id, int userId)
        {
            var comment = await _context.Comments.FirstOrDefaultAsync(c => c.Id == id);

            if (comment == null || comment.UserId != userId)
                return false;

            _context.Comments.Remove(comment);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> ToggleLikeAsync(int commentId, int userId)
        {
            var existingLike = await _context.CommentLikes
                .FirstOrDefaultAsync(cl => cl.CommentId == commentId && cl.UserId == userId);

            if (existingLike != null)
            {
                _context.CommentLikes.Remove(existingLike);
            }
            else
            {
                var like = new CommentLike
                {
                    CommentId = commentId,
                    UserId = userId
                };
                _context.CommentLikes.Add(like);
            }

            await _context.SaveChangesAsync();
            return existingLike == null; // Return true if liked, false if unliked
        }

        private CommentDto MapToDto(Comment comment, int? userId = null)
        {
            return new CommentDto
            {
                Id = comment.Id,
                TopicId = comment.TopicId,
                Content = comment.Content,
                AuthorName = comment.AuthorName,
                AuthorEmail = comment.AuthorEmail,
                CreatedAt = comment.CreatedAt,
                UpdatedAt = comment.UpdatedAt,
                LikeCount = comment.LikeCount,
                IsLiked = userId.HasValue && comment.CommentLikes.Any(cl => cl.UserId == userId.Value)
            };
        }
    }
}