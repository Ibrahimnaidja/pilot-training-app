namespace MathQuiz.Api.Models;

public class UserStats
{
    public Guid UserId { get; set; }
    public User? User { get; set; }

    public int CurrentStreak { get; set; }
    public int BestStreak { get; set; }
    public int TotalCorrect { get; set; }
    public int TotalAttempts { get; set; }
}
