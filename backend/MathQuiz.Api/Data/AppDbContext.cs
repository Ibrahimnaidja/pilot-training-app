using MathQuiz.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace MathQuiz.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Problem> Problems => Set<Problem>();
    public DbSet<Attempt> Attempts => Set<Attempt>();
    public DbSet<UserStats> UserStats => Set<UserStats>();
    public DbSet<LogicAttempt> LogicAttempts => Set<LogicAttempt>();
    public DbSet<LogicStats> LogicStats => Set<LogicStats>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>()
            .HasIndex(u => u.Username)
            .IsUnique();

        modelBuilder.Entity<UserStats>()
            .HasKey(s => s.UserId);

        modelBuilder.Entity<UserStats>()
            .HasOne(s => s.User)
            .WithOne(u => u.Stats)
            .HasForeignKey<UserStats>(s => s.UserId);

        modelBuilder.Entity<Problem>()
            .HasOne(p => p.CreatedByUser)
            .WithMany(u => u.CreatedProblems)
            .HasForeignKey(p => p.CreatedByUserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Attempt>()
            .HasOne(a => a.User)
            .WithMany(u => u.Attempts)
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Attempt>()
            .HasOne(a => a.Problem)
            .WithMany()
            .HasForeignKey(a => a.ProblemId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<LogicStats>()
            .HasKey(s => s.UserId);

        modelBuilder.Entity<LogicStats>()
            .HasOne(s => s.User)
            .WithMany()
            .HasForeignKey(s => s.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<LogicAttempt>()
            .HasOne(a => a.User)
            .WithMany()
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
