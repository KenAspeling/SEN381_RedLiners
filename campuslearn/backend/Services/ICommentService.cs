using CampusLearnBackend.DTOs;

namespace CampusLearnBackend.Services
{
    public interface ICommentService
    {
        Task<IEnumerable<CommentDto>> GetCommentsByTopicAsync(int topicId, int? userId = null);
        Task<IEnumerable<CommentDto>> GetCommentsByUserAsync(int userId, int? currentUserId = null);
        Task<CommentDto> CreateCommentAsync(CreateCommentDto createCommentDto, int userId);
        Task<CommentDto?> UpdateCommentAsync(int id, UpdateCommentDto updateCommentDto, int userId);
        Task<bool> DeleteCommentAsync(int id, int userId);
        Task<bool> ToggleLikeAsync(int commentId, int userId);
    }
}