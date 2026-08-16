using System.Security.Claims;
using MathQuiz.Api.Data;
using MathQuiz.Api.Dtos;
using MathQuiz.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace MathQuiz.Api.Endpoints;

public static class AttemptEndpoints
{
    public static void MapAttemptEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/attempts").RequireAuthorization();

        group.MapPost("/", async (SubmitAttemptRequest req, ClaimsPrincipal principal, AppDbContext db) =>
        {
            var userId = principal.GetUserId();

            var problem = await db.Problems.FindAsync(req.ProblemId);
            if (problem is null)
                return Results.NotFound(new { error = "Problem not found." });

            var isCorrect = !req.TimedOut && req.Answer.HasValue && req.Answer.Value == problem.CorrectAnswer;

            var attempt = new Attempt
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                ProblemId = problem.Id,
                SubmittedAnswer = req.Answer ?? 0,
                IsCorrect = isCorrect,
                TimedOut = req.TimedOut
            };
            db.Attempts.Add(attempt);

            var stats = await db.UserStats.FirstOrDefaultAsync(s => s.UserId == userId);
            if (stats is null)
            {
                stats = new Models.UserStats { UserId = userId };
                db.UserStats.Add(stats);
            }

            stats.TotalAttempts += 1;
            if (isCorrect)
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

            return Results.Ok(new AttemptResultResponse(
                isCorrect, problem.CorrectAnswer,
                stats.CurrentStreak, stats.BestStreak, stats.TotalCorrect, stats.TotalAttempts));
        });
    }
}
