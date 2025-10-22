namespace CampusLearnBackend.Services
{
    public interface IEmailService
    {
        /// <summary>
        /// Send an email notification
        /// </summary>
        Task<bool> SendEmailAsync(string toEmail, string toName, string subject, string body);

        /// <summary>
        /// Send notification email with template
        /// </summary>
        Task<bool> SendNotificationEmailAsync(string toEmail, string toName, string notificationType, string title, string message, string? actionUrl = null);

        /// <summary>
        /// Send bulk emails
        /// </summary>
        Task<int> SendBulkEmailsAsync(List<(string email, string name, string subject, string body)> emails);
    }
}
