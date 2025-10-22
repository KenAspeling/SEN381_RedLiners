using Microsoft.EntityFrameworkCore;
using CampusLearnBackend.Models;

namespace CampusLearnBackend.Data
{
    public class CampusLearnContext : DbContext
    {
        public CampusLearnContext(DbContextOptions<CampusLearnContext> options) : base(options)
        {
        }

        // Lookup tables
        public DbSet<AccessType> AccessTypes { get; set; }
        public DbSet<PostType> PostTypes { get; set; }
        public DbSet<StatusType> StatusTypes { get; set; }
        public DbSet<SubscribableType> SubscribableTypes { get; set; }

        // Core entities
        public DbSet<User> Users { get; set; }
        public DbSet<Module> Modules { get; set; }
        public DbSet<Material> Materials { get; set; }
        public DbSet<Post> Posts { get; set; }
        public DbSet<Like> Likes { get; set; }
        public DbSet<Subscription> Subscriptions { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<FcmToken> FcmTokens { get; set; }
        public DbSet<DirectMessage> DirectMessages { get; set; }
        public DbSet<QueryTicket> QueryTickets { get; set; }
        public DbSet<Response> Responses { get; set; }
        public DbSet<UserModule> UserModules { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure lookup tables - IDs are manually assigned, not auto-generated
            modelBuilder.Entity<AccessType>()
                .Property(e => e.AccessId)
                .ValueGeneratedNever();

            modelBuilder.Entity<PostType>()
                .Property(e => e.TypeId)
                .ValueGeneratedNever();

            modelBuilder.Entity<StatusType>()
                .Property(e => e.StatusId)
                .ValueGeneratedNever();

            modelBuilder.Entity<SubscribableType>()
                .Property(e => e.TypeId)
                .ValueGeneratedNever();

            // Configure UserModule composite primary key
            modelBuilder.Entity<UserModule>()
                .HasKey(um => new { um.UserId, um.ModuleId });

            // Configure unique constraint for likes (user can only like a post once)
            modelBuilder.Entity<Like>()
                .HasIndex(e => new { e.UserId, e.PostId })
                .IsUnique();

            // Configure unique constraint for subscriptions (user can only subscribe once to same type+id)
            modelBuilder.Entity<Subscription>()
                .HasIndex(e => new { e.UserId, e.SubscribableType, e.SubscribableId })
                .IsUnique();

            // Configure unique constraint for FCM tokens (token must be unique)
            modelBuilder.Entity<FcmToken>()
                .HasIndex(e => e.Token)
                .IsUnique();

            // Configure DirectMessage relationships to avoid circular references
            modelBuilder.Entity<DirectMessage>()
                .HasOne(dm => dm.Sender)
                .WithMany(u => u.SentMessages)
                .HasForeignKey(dm => dm.SenderId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<DirectMessage>()
                .HasOne(dm => dm.Recipient)
                .WithMany(u => u.ReceivedMessages)
                .HasForeignKey(dm => dm.RecipientId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure Post self-referencing relationship for parent/child (comments)
            modelBuilder.Entity<Post>()
                .HasOne(p => p.ParentPost)
                .WithMany(p => p.ChildPosts)
                .HasForeignKey(p => p.ParentPostId)
                .OnDelete(DeleteBehavior.Cascade);

            // Seed lookup tables with initial data
            modelBuilder.Entity<AccessType>().HasData(
                new AccessType { AccessId = 1, Name = "student" },
                new AccessType { AccessId = 2, Name = "tutor" },
                new AccessType { AccessId = 3, Name = "admin" }
            );

            modelBuilder.Entity<PostType>().HasData(
                new PostType { TypeId = 1, Name = "comment" },
                new PostType { TypeId = 2, Name = "post" },
                new PostType { TypeId = 3, Name = "topic" }
            );

            modelBuilder.Entity<StatusType>().HasData(
                new StatusType { StatusId = 1, Name = "sent" },
                new StatusType { StatusId = 2, Name = "received" },
                new StatusType { StatusId = 3, Name = "responded" }
            );

            modelBuilder.Entity<SubscribableType>().HasData(
                new SubscribableType { TypeId = 1, Name = "topic" },
                new SubscribableType { TypeId = 2, Name = "module" }
            );
        }

        public override int SaveChanges()
        {
            SetTimestamps();
            return base.SaveChanges();
        }

        public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            SetTimestamps();
            return await base.SaveChangesAsync(cancellationToken);
        }

        private void SetTimestamps()
        {
            var entries = ChangeTracker.Entries()
                .Where(e => e.State == EntityState.Added);

            foreach (var entry in entries)
            {
                // Set TimeCreated for new entities (only if the property exists)
                try
                {
                    var timeCreatedProperty = entry.Property("TimeCreated");
                    if (timeCreatedProperty != null)
                    {
                        timeCreatedProperty.CurrentValue = DateTime.UtcNow;
                    }
                }
                catch (InvalidOperationException)
                {
                    // Property doesn't exist on this entity (e.g., UserModule), skip it
                }
            }
        }
    }
}