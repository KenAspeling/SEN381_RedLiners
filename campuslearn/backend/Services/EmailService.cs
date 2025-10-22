using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using Microsoft.Extensions.Configuration;

namespace CampusLearnBackend.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly string _smtpHost;
        private readonly int _smtpPort;
        private readonly string _smtpUsername;
        private readonly string _smtpPassword;
        private readonly string _fromEmail;
        private readonly string _fromName;

        public EmailService(IConfiguration configuration)
        {
            _configuration = configuration;
            _smtpHost = configuration["Email:SmtpHost"] ?? "smtp.gmail.com";
            _smtpPort = int.Parse(configuration["Email:SmtpPort"] ?? "587");
            _smtpUsername = configuration["Email:SmtpUsername"] ?? "";
            _smtpPassword = configuration["Email:SmtpPassword"] ?? "";
            _fromEmail = configuration["Email:FromEmail"] ?? _smtpUsername;
            _fromName = configuration["Email:FromName"] ?? "Campus Learn";
        }

        public async Task<bool> SendEmailAsync(string toEmail, string toName, string subject, string body)
        {
            try
            {
                var message = new MimeMessage();
                message.From.Add(new MailboxAddress(_fromName, _fromEmail));
                message.To.Add(new MailboxAddress(toName, toEmail));
                message.Subject = subject;

                var bodyBuilder = new BodyBuilder
                {
                    HtmlBody = body
                };
                message.Body = bodyBuilder.ToMessageBody();

                using var client = new SmtpClient();
                await client.ConnectAsync(_smtpHost, _smtpPort, SecureSocketOptions.StartTls);
                await client.AuthenticateAsync(_smtpUsername, _smtpPassword);
                await client.SendAsync(message);
                await client.DisconnectAsync(true);

                Console.WriteLine($"[EMAIL] Sent to {toEmail}: {subject}");
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[EMAIL ERROR] Failed to send to {toEmail}: {ex.Message}");
                return false;
            }
        }

        public async Task<bool> SendNotificationEmailAsync(
            string toEmail,
            string toName,
            string notificationType,
            string title,
            string message,
            string? actionUrl = null)
        {
            var subject = $"Campus Learn: {title}";
            var body = BuildNotificationEmailTemplate(toName, notificationType, title, message, actionUrl);

            return await SendEmailAsync(toEmail, toName, subject, body);
        }

        public async Task<int> SendBulkEmailsAsync(List<(string email, string name, string subject, string body)> emails)
        {
            int successCount = 0;

            foreach (var email in emails)
            {
                var success = await SendEmailAsync(email.email, email.name, email.subject, email.body);
                if (success)
                {
                    successCount++;
                }

                // Small delay to avoid rate limiting
                await Task.Delay(100);
            }

            Console.WriteLine($"[EMAIL BULK] Sent {successCount}/{emails.Count} emails");
            return successCount;
        }

        private string BuildNotificationEmailTemplate(
            string userName,
            string notificationType,
            string title,
            string message,
            string? actionUrl)
        {
            var iconEmoji = notificationType switch
            {
                "comment" => "💬",
                "new_post" => "📝",
                "new_topic" => "📌",
                "like" => "❤️",
                "message" => "✉️",
                "ticket_response" => "💡",
                "new_ticket" => "🎫",
                _ => "🔔"
            };

            var actionButton = !string.IsNullOrEmpty(actionUrl)
                ? $@"
                <div style=""text-align: center; margin-top: 30px;"">
                    <a href=""{actionUrl}"" style=""display: inline-block; padding: 12px 30px; background-color: #2563eb; color: white; text-decoration: none; border-radius: 6px; font-weight: 600;"">View in Campus Learn</a>
                </div>"
                : "";

            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset=""UTF-8"">
    <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"">
    <title>{title}</title>
</head>
<body style=""margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f3f4f6;"">
    <table width=""100%"" cellpadding=""0"" cellspacing=""0"" style=""background-color: #f3f4f6; padding: 20px;"">
        <tr>
            <td align=""center"">
                <table width=""600"" cellpadding=""0"" cellspacing=""0"" style=""background-color: white; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);"">
                    <!-- Header -->
                    <tr>
                        <td style=""background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%); padding: 30px; text-align: center; border-radius: 12px 12px 0 0;"">
                            <h1 style=""color: white; margin: 0; font-size: 28px;"">🎓 Campus Learn</h1>
                        </td>
                    </tr>

                    <!-- Content -->
                    <tr>
                        <td style=""padding: 40px 30px;"">
                            <p style=""color: #6b7280; font-size: 16px; margin: 0 0 10px 0;"">Hi {userName},</p>

                            <div style=""background-color: #eff6ff; border-left: 4px solid #2563eb; padding: 20px; margin: 20px 0; border-radius: 6px;"">
                                <div style=""font-size: 48px; text-align: center; margin-bottom: 10px;"">{iconEmoji}</div>
                                <h2 style=""color: #1e293b; margin: 0 0 10px 0; font-size: 20px;"">{title}</h2>
                                <p style=""color: #475569; margin: 0; font-size: 15px; line-height: 1.6;"">{message}</p>
                            </div>

                            {actionButton}

                            <div style=""margin-top: 40px; padding-top: 20px; border-top: 1px solid #e5e7eb; color: #6b7280; font-size: 13px;"">
                                <p style=""margin: 5px 0;"">This is an automated notification from Campus Learn.</p>
                                <p style=""margin: 5px 0;"">To manage your notification preferences, visit your profile settings.</p>
                            </div>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style=""background-color: #f9fafb; padding: 20px; text-align: center; border-radius: 0 0 12px 12px; color: #9ca3af; font-size: 12px;"">
                            <p style=""margin: 5px 0;"">&copy; {DateTime.Now.Year} Campus Learn. All rights reserved.</p>
                            <p style=""margin: 5px 0;"">Helping students learn together.</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>";
        }
    }
}
