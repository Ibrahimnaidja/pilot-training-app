using MathQuiz.Api.Models;

namespace MathQuiz.Api.Dtos;

public record CreateProblemRequest(int Num1, int Num2, MathOperator Operator);

public record ProblemResponse(Guid Id, int Num1, int Num2, MathOperator Operator, string DisplayExpression, string CreatedByUsername);

public record SubmitAttemptRequest(Guid ProblemId, int? Answer, bool TimedOut);

public record AttemptResultResponse(bool Correct, int CorrectAnswer, int CurrentStreak, int BestStreak, int TotalCorrect, int TotalAttempts);

public record StatsResponse(int CurrentStreak, int BestStreak, int TotalCorrect, int TotalAttempts);

public record LeaderboardEntry(string Username, int BestStreak, int TotalCorrect, int TotalAttempts);
