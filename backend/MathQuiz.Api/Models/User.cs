namespace MathQuiz.Api.Models;

public class User
{
    public Guid Id { get; set; }
    public required string Username { get; set; }
    public required string PasswordHash { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;

    public List<Problem> CreatedProblems { get; set; } = new();
    public List<Attempt> Attempts { get; set; } = new();
    public UserStats? Stats { get; set; }
}
