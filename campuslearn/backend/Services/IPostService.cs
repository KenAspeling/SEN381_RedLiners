using CampusLearnBackend.DTOs;

namespace CampusLearnBackend.Services
{
    public interface IPostService
    {
        Task<List<PostDto>> GetAllPostsAsync(int? currentUserId = null);
        Task<PostDto?> GetPostByIdAsync(int postId, int? currentUserId = null);
        Task<List<PostDto>> GetPostsByUserIdAsync(int userId, int? currentUserId = null);
        Task<List<PostDto>> GetCommentsByUserIdAsync(int userId, int? currentUserId = null);
        Task<PostDto?> CreatePostAsync(CreatePostDto createPostDto, int userId);
        Task<PostDto?> UpdatePostAsync(int postId, UpdatePostDto updatePostDto, int userId);
        Task<bool> DeletePostAsync(int postId, int userId);
        Task<bool> ToggleLikeAsync(int postId, int userId);
        Task<List<PostDto>> GetCommentsAsync(int postId, int? currentUserId = null);
        Task<List<PostDto>> GetLikedPostsByUserAsync(int userId);
    }
}
