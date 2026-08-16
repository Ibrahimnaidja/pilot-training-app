using System.Security.Claims;
using MathQuiz.Api.Data;
using MathQuiz.Api.Dtos;
using MathQuiz.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace MathQuiz.Api.Endpoints;

public static class ProblemEndpoints
{
    // Keeps problems in a sane, two-digit-friendly range and rejects
    // subtraction that would go negative.
    private static string? Validate(int num1, int num2, MathOperator op)
    {
        if (num1 < 1 || num1 > 99 || num2 < 1 || num2 > 99)
            return "Numbers must be between 1 and 99.";
        if (op == MathOperator.Subtract && num2 > num1)
            return "Subtraction can't go negative — the first number must be greater than or equal to the second.";
        if (op == MathOperator.Multiply && num1 * num2 > 9801)
            return "That product is too large — keep it reasonable.";
        return null;
    }

    public static void MapProblemEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/problems").RequireAuthorization();

        group.MapPost("/", async (CreateProblemRequest req, ClaimsPrincipal principal, AppDbContext db) =>
        {
            var validationError = Validate(req.Num1, req.Num2, req.Operator);
            if (validationError is not null)
                return Results.BadRequest(new { error = validationError });

            var userId = principal.GetUserId();
            var answer = Compute(req.Num1, req.Num2, req.Operator);

            var problem = new Problem
            {
                Id = Guid.NewGuid(),
                Num1 = req.Num1,
                Num2 = req.Num2,
                Operator = req.Operator,
                CorrectAnswer = answer,
                CreatedByUserId = userId
            };

            db.Problems.Add(problem);
            await db.SaveChangesAsync();

            return Results.Ok(new ProblemResponse(problem.Id, problem.Num1, problem.Num2, problem.Operator, problem.DisplayExpression, principal.GetUsername()));
        });

        group.MapPut("/{id:guid}", async (Guid id, CreateProblemRequest req, ClaimsPrincipal principal, AppDbContext db) =>
        {
            var validationError = Validate(req.Num1, req.Num2, req.Operator);
            if (validationError is not null)
                return Results.BadRequest(new { error = validationError });

            var userId = principal.GetUserId();
            var problem = await db.Problems.FindAsync(id);
            if (problem is null)
                return Results.NotFound(new { error = "Problem not found." });
            if (problem.CreatedByUserId != userId)
                return Results.Forbid();

            problem.Num1 = req.Num1;
            problem.Num2 = req.Num2;
            problem.Operator = req.Operator;
            problem.CorrectAnswer = Compute(req.Num1, req.Num2, req.Operator);
            await db.SaveChangesAsync();

            return Results.Ok(new ProblemResponse(problem.Id, problem.Num1, problem.Num2, problem.Operator, problem.DisplayExpression, principal.GetUsername()));
        });

        group.MapDelete("/{id:guid}", async (Guid id, ClaimsPrincipal principal, AppDbContext db) =>
        {
            var userId = principal.GetUserId();
            var problem = await db.Problems.FindAsync(id);
            if (problem is null)
                return Results.NotFound(new { error = "Problem not found." });
            if (problem.CreatedByUserId != userId)
                return Results.Forbid();

            db.Problems.Remove(problem);
            await db.SaveChangesAsync();
            return Results.NoContent();
        });

        // A random problem created by someone else. Falls back to your own
        // problems only if no one else has made any yet.
        group.MapGet("/random", async (ClaimsPrincipal principal, AppDbContext db) =>
        {
            var userId = principal.GetUserId();

            var candidate = await db.Problems
                .Include(p => p.CreatedByUser)
                .Where(p => p.CreatedByUserId != userId)
                .OrderBy(p => EF.Functions.Random())
                .FirstOrDefaultAsync();

            candidate ??= await db.Problems
                .Include(p => p.CreatedByUser)
                .OrderBy(p => EF.Functions.Random())
                .FirstOrDefaultAsync();

            if (candidate is null)
                return Results.NotFound(new { error = "No problems exist yet. Create one first." });

            return Results.Ok(new ProblemResponse(
                candidate.Id, candidate.Num1, candidate.Num2, candidate.Operator,
                candidate.DisplayExpression, candidate.CreatedByUser?.Username ?? "unknown"));
        });

        group.MapGet("/mine", async (ClaimsPrincipal principal, AppDbContext db) =>
        {
            var userId = principal.GetUserId();
            var username = principal.GetUsername();
            var problems = await db.Problems
                .Where(p => p.CreatedByUserId == userId)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();
            var response = problems
                .Select(p => new ProblemResponse(p.Id, p.Num1, p.Num2, p.Operator, p.DisplayExpression, username))
                .ToList();
            return Results.Ok(response);
        });
    }

    private static int Compute(int num1, int num2, MathOperator op) => op switch
    {
        MathOperator.Add => num1 + num2,
        MathOperator.Subtract => num1 - num2,
        MathOperator.Multiply => num1 * num2,
        _ => throw new ArgumentOutOfRangeException()
    };
}
