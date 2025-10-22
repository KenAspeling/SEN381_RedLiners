namespace CampusLearnBackend.DTOs
{
    public class SubscriptionDto
    {
        public int SubscriptionId { get; set; }
        public int UserId { get; set; }
        public int SubscribableType { get; set; } // 1 = Topic, 2 = Module
        public int SubscribableId { get; set; }
        public DateTime TimeCreated { get; set; }
    }

    public class CreateSubscriptionDto
    {
        public int SubscribableType { get; set; } // 1 = Topic, 2 = Module
        public int SubscribableId { get; set; }
    }
}
