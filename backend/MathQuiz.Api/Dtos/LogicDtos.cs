using MathQuiz.Api.Models;

namespace MathQuiz.Api.Dtos;

public record SubmitLogicAttemptRequest(LogicCategory Category, bool Correct);

public record LogicAttemptResultResponse(int CurrentStreak, int BestStreak, int TotalCorrect, int TotalAttempts);

public record LogicStatsResponse(int CurrentStreak, int BestStreak, int TotalCorrect, int TotalAttempts);
