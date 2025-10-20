using Microsoft.EntityFrameworkCore;
using CampusLearnBackend.Models;

namespace CampusLearnBackend.Data
{
    public class CampusLearnContext : DbContext
    {
        public CampusLearnContext(DbContextOptions<CampusLearnContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Tutor> Tutors { get; set; }
        public DbSet<Topic> Topics { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<TopicLike> TopicLikes { get; set; }
        public DbSet<CommentLike> CommentLikes { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure lowercase table names for PostgreSQL
            modelBuilder.Entity<User>().ToTable("users");
            modelBuilder.Entity<Tutor>().ToTable("tutors");
            modelBuilder.Entity<Topic>().ToTable("topics");
            modelBuilder.Entity<Comment>().ToTable("comments");
            modelBuilder.Entity<TopicLike>().ToTable("topic_likes");
            modelBuilder.Entity<CommentLike>().ToTable("comment_likes");

            // User entity configuration
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("user_id");
                entity.Property(e => e.Email).HasColumnName("email").IsRequired().HasMaxLength(255);
                entity.Property(e => e.Name).HasColumnName("name").IsRequired().HasMaxLength(100);
                entity.Property(e => e.EncryptedPassword).HasColumnName("encrypted_password").IsRequired();
                entity.Property(e => e.IsTutor).HasColumnName("is_tutor");
                entity.Property(e => e.CreatedAt).HasColumnName("time_created");
                entity.Ignore(e => e.UpdatedAt); // No updated_at in database
                entity.Ignore(e => e.Tutor); // Ignore tutor navigation for now
                entity.HasIndex(e => e.Email).IsUnique();
            });

            // Tutor entity configuration - using is_tutor flag instead
            // The tutors table exists but we'll check is_tutor column in users table
            modelBuilder.Entity<Tutor>().ToTable("tutors", t => t.ExcludeFromMigrations());
            modelBuilder.Entity<Tutor>(entity =>
            {
                entity.HasKey(e => e.UserId);
                entity.Property(e => e.UserId).HasColumnName("tutor_id");
                entity.Ignore(e => e.CreatedAt);
                entity.Ignore(e => e.UpdatedAt);
                entity.Ignore(e => e.User); // Ignore navigation to avoid circular reference issues
            });

            // Topic entity configuration
            modelBuilder.Entity<Topic>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("topic_id");
                entity.Property(e => e.Title).HasColumnName("title").IsRequired().HasMaxLength(255);
                entity.Property(e => e.Content).HasColumnName("content").IsRequired();
                entity.Property(e => e.UserId).HasColumnName("created_by");
                entity.Property(e => e.CreatedAt).HasColumnName("time_created");
                entity.Property(e => e.UpdatedAt).HasColumnName("time_updated");
                entity.Property(e => e.ViewCount).HasColumnName("view_count");
                entity.Ignore(e => e.IsAnnouncement); // No is_announcement in database
                entity.HasOne(e => e.User)
                      .WithMany(u => u.Topics)
                      .HasForeignKey(e => e.UserId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // Comment entity configuration
            modelBuilder.Entity<Comment>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("comment_id");
                entity.Property(e => e.Content).HasColumnName("content").IsRequired();
                entity.Property(e => e.TopicId).HasColumnName("topic_id");
                entity.Property(e => e.UserId).HasColumnName("user_id");
                entity.Property(e => e.CreatedAt).HasColumnName("time_created");
                entity.Ignore(e => e.UpdatedAt); // No updated_at in database
                entity.HasOne(e => e.Topic)
                      .WithMany(t => t.Comments)
                      .HasForeignKey(e => e.TopicId)
                      .OnDelete(DeleteBehavior.Cascade);
                entity.HasOne(e => e.User)
                      .WithMany(u => u.Comments)
                      .HasForeignKey(e => e.UserId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // TopicLike entity configuration
            modelBuilder.Entity<TopicLike>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("like_id");
                entity.Property(e => e.TopicId).HasColumnName("topic_id");
                entity.Property(e => e.UserId).HasColumnName("user_id");
                entity.Property(e => e.CreatedAt).HasColumnName("time_liked");
                entity.HasIndex(e => new { e.TopicId, e.UserId }).IsUnique();
                entity.HasOne(e => e.Topic)
                      .WithMany(t => t.TopicLikes)
                      .HasForeignKey(e => e.TopicId)
                      .OnDelete(DeleteBehavior.Cascade);
                entity.HasOne(e => e.User)
                      .WithMany(u => u.TopicLikes)
                      .HasForeignKey(e => e.UserId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // CommentLike entity configuration
            modelBuilder.Entity<CommentLike>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("like_id");
                entity.Property(e => e.CommentId).HasColumnName("comment_id");
                entity.Property(e => e.UserId).HasColumnName("user_id");
                entity.Property(e => e.CreatedAt).HasColumnName("time_liked");
                entity.HasIndex(e => new { e.CommentId, e.UserId }).IsUnique();
                entity.HasOne(e => e.Comment)
                      .WithMany(c => c.CommentLikes)
                      .HasForeignKey(e => e.CommentId)
                      .OnDelete(DeleteBehavior.Cascade);
                entity.HasOne(e => e.User)
                      .WithMany(u => u.CommentLikes)
                      .HasForeignKey(e => e.UserId)
                      .OnDelete(DeleteBehavior.Cascade);
            });
        }

        public override int SaveChanges()
        {
            UpdateTimestamps();
            return base.SaveChanges();
        }

        public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            UpdateTimestamps();
            return await base.SaveChangesAsync(cancellationToken);
        }

        private void UpdateTimestamps()
        {
            var entries = ChangeTracker.Entries()
                .Where(e => e.Entity is User || e.Entity is Topic || e.Entity is Comment || e.Entity is Tutor)
                .Where(e => e.State == EntityState.Added || e.State == EntityState.Modified);

            foreach (var entry in entries)
            {
                if (entry.State == EntityState.Added)
                {
                    if (entry.Property("CreatedAt") != null)
                        entry.Property("CreatedAt").CurrentValue = DateTime.UtcNow;
                }

                if (entry.Property("UpdatedAt") != null)
                    entry.Property("UpdatedAt").CurrentValue = DateTime.UtcNow;
            }
        }
    }
}