using MathQuiz.Api.Data;
using MathQuiz.Api.Dtos;
using MathQuiz.Api.Models;
using MathQuiz.Api.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace MathQuiz.Api.Endpoints;

public static class AuthEndpoints
{
    public static void MapAuthEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/auth");
        var hasher = new PasswordHasher<User>();

        group.MapPost("/register", async (RegisterRequest req, AppDbContext db, TokenService tokens) =>
        {
            var username = req.Username?.Trim() ?? "";
            if (username.Length < 3 || username.Length > 32)
                return Results.BadRequest(new { error = "Username must be 3-32 characters." });
            if (string.IsNullOrEmpty(req.Password) || req.Password.Length < 6)
                return Results.BadRequest(new { error = "Password must be at least 6 characters." });

            var exists = await db.Users.AnyAsync(u => u.Username.ToLower() == username.ToLower());
            if (exists)
                return Results.Conflict(new { error = "That username is already taken." });

            var user = new User { Id = Guid.NewGuid(), Username = username, PasswordHash = "" };
            user.PasswordHash = hasher.HashPassword(user, req.Password);

            db.Users.Add(user);
            db.UserStats.Add(new Models.UserStats { UserId = user.Id });
            await db.SaveChangesAsync();

            var token = tokens.CreateToken(user);
            return Results.Ok(new AuthResponse(token, user.Username, user.Id));
        });

        group.MapPost("/login", async (LoginRequest req, AppDbContext db, TokenService tokens) =>
        {
            var user = await db.Users.FirstOrDefaultAsync(u => u.Username.ToLower() == req.Username.ToLower());
            if (user is null)
                return Results.Unauthorized();

            var result = hasher.VerifyHashedPassword(user, user.PasswordHash, req.Password);
            if (result == PasswordVerificationResult.Failed)
                return Results.Unauthorized();

            var token = tokens.CreateToken(user);
            return Results.Ok(new AuthResponse(token, user.Username, user.Id));
        });
    }
}
