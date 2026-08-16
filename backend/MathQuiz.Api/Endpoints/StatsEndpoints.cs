using System.Security.Claims;
using MathQuiz.Api.Data;
using MathQuiz.Api.Dtos;
using Microsoft.EntityFrameworkCore;

namespace MathQuiz.Api.Endpoints;

public static class StatsEndpoints
{
    public static void MapStatsEndpoints(this WebApplication app)
    {
        app.MapGet("/api/me/stats", async (ClaimsPrincipal principal, AppDbContext db) =>
        {
            var userId = principal.GetUserId();
            var stats = await db.UserStats.FirstOrDefaultAsync(s => s.UserId == userId);
            stats ??= new Models.UserStats { UserId = userId };
            return Results.Ok(new StatsResponse(stats.CurrentStreak, stats.BestStreak, stats.TotalCorrect, stats.TotalAttempts));
        }).RequireAuthorization();

        app.MapGet("/api/leaderboard", async (AppDbContext db) =>
        {
            var top = await db.UserStats
                .Include(s => s.User)
                .OrderByDescending(s => s.BestStreak)
                .ThenByDescending(s => s.TotalCorrect)
                .Take(20)
                .Select(s => new LeaderboardEntry(s.User!.Username, s.BestStreak, s.TotalCorrect, s.TotalAttempts))
                .ToListAsync();
            return Results.Ok(top);
        }).RequireAuthorization();
    }
}
