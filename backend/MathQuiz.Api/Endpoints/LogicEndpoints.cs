using System.Security.Claims;
using MathQuiz.Api.Data;
using MathQuiz.Api.Dtos;
using MathQuiz.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace MathQuiz.Api.Endpoints;

public static class LogicEndpoints
{
    public static void MapLogicEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/logic").RequireAuthorization();

        group.MapPost("/attempts", async (SubmitLogicAttemptRequest req, ClaimsPrincipal principal, AppDbContext db) =>
        {
            var userId = principal.GetUserId();

            db.LogicAttempts.Add(new LogicAttempt
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Category = req.Category,
                IsCorrect = req.Correct
            });

            var stats = await db.LogicStats.FirstOrDefaultAsync(s => s.UserId == userId);
            if (stats is null)
            {
                stats = new LogicStats { UserId = userId };
                db.LogicStats.Add(stats);
            }

            stats.TotalAttempts += 1;
            if (req.Correct)
            {
                stats.TotalCorrect += 1;
                stats.CurrentStreak += 1;
                stats.BestStreak = Math.Max(stats.BestStreak, stats.CurrentStreak);
            }
            else
            {
                stats.CurrentStreak = 0;
            }

            await db.SaveChangesAsync();

            return Results.Ok(new LogicAttemptResultResponse(
                stats.CurrentStreak, stats.BestStreak, stats.TotalCorrect, stats.TotalAttempts));
        });

        group.MapGet("/stats", async (ClaimsPrincipal principal, AppDbContext db) =>
        {
            var userId = principal.GetUserId();
            var stats = await db.LogicStats.FirstOrDefaultAsync(s => s.UserId == userId);
            stats ??= new LogicStats { UserId = userId };
            return Results.Ok(new LogicStatsResponse(stats.CurrentStreak, stats.BestStreak, stats.TotalCorrect, stats.TotalAttempts));
        });
    }
}
