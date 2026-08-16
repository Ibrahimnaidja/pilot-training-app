using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using MathQuiz.Api.Models;
using Microsoft.IdentityModel.Tokens;

namespace MathQuiz.Api.Services;

public class TokenService(IConfiguration config)
{
    public string CreateToken(User user)
    {
        var secret = config["Jwt:Secret"]
            ?? throw new InvalidOperationException("Jwt:Secret is not configured.");

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.UniqueName, user.Username),
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: config["Jwt:Issuer"] ?? "math-quiz-api",
            audience: config["Jwt:Audience"] ?? "math-quiz-app",
            claims: claims,
            expires: DateTime.UtcNow.AddDays(30),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
