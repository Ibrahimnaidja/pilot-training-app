namespace MathQuiz.Api.Models;

public class Attempt
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }
    public User? User { get; set; }

    public Guid ProblemId { get; set; }
    public Problem? Problem { get; set; }

    public int SubmittedAnswer { get; set; }
    public bool IsCorrect { get; set; }
    public bool TimedOut { get; set; }

    public DateTimeOffset AnsweredAt { get; set; } = DateTimeOffset.UtcNow;
}
