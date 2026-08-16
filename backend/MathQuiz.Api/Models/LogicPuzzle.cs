namespace MathQuiz.Api.Models;

public enum LogicCategory
{
    NumberSequence,
    Diagrammatic,
    Verbal,
    DataInterpretation
}

// Puzzle generation and answer-checking both happen on-device in the Flutter
// app; the backend only ever sees the outcome of an already-graded attempt.
public class LogicAttempt
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }
    public User? User { get; set; }

    public LogicCategory Category { get; set; }
    public bool IsCorrect { get; set; }

    public DateTimeOffset AnsweredAt { get; set; } = DateTimeOffset.UtcNow;
}

public class LogicStats
{
    public Guid UserId { get; set; }
    public User? User { get; set; }

    public int CurrentStreak { get; set; }
    public int BestStreak { get; set; }
    public int TotalCorrect { get; set; }
    public int TotalAttempts { get; set; }
}
