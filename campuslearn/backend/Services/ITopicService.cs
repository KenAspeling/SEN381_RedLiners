using CampusLearnBackend.DTOs;
using CampusLearnBackend.Models;

namespace CampusLearnBackend.Services
{
    public interface ITopicService
    {
        Task<IEnumerable<TopicDto>> GetAllTopicsAsync(int? userId = null);
        Task<TopicDto?> GetTopicByIdAsync(int id, int? userId = null);
        Task<IEnumerable<TopicDto>> GetTopicsByUserAsync(int userId, int? currentUserId = null);
        Task<TopicDto> CreateTopicAsync(CreateTopicDto createTopicDto, int userId);
        Task<TopicDto?> UpdateTopicAsync(int id, UpdateTopicDto updateTopicDto, int userId);
        Task<bool> DeleteTopicAsync(int id, int userId);
        Task<bool> ToggleLikeAsync(int topicId, int userId);
        Task<bool> IncrementViewCountAsync(int topicId);
        Task<IEnumerable<TopicDto>> SearchTopicsAsync(string query, int? userId = null);
        Task<IEnumerable<TopicDto>> GetTrendingTopicsAsync(int? userId = null);
    }
}