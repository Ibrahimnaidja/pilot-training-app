namespace MathQuiz.Api.Models;

public enum MathOperator
{
    Add,
    Subtract,
    Multiply
}

public class Problem
{
    public Guid Id { get; set; }
    public int Num1 { get; set; }
    public int Num2 { get; set; }
    public MathOperator Operator { get; set; }

    // Precomputed so every attempt is checked consistently, and so we never
    // have to re-derive it (e.g. if operator semantics ever change).
    public int CorrectAnswer { get; set; }

    public Guid CreatedByUserId { get; set; }
    public User? CreatedByUser { get; set; }

    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;

    public string DisplayExpression =>
        Operator switch
        {
            MathOperator.Add => $"{Num1} + {Num2}",
            MathOperator.Subtract => $"{Num1} - {Num2}",
            MathOperator.Multiply => $"{Num1} \u00d7 {Num2}",
            _ => $"{Num1} ? {Num2}"
        };
}
