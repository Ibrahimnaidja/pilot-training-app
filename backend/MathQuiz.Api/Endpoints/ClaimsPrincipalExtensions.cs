using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace MathQuiz.Api.Endpoints;

public static class ClaimsPrincipalExtensions
{
    public static Guid GetUserId(this ClaimsPrincipal principal)
    {
        var value = principal.FindFirstValue(JwtRegisteredClaimNames.Sub)
            ?? principal.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new InvalidOperationException("No user id claim present.");
        return Guid.Parse(value);
    }

    public static string GetUsername(this ClaimsPrincipal principal)
    {
        return principal.FindFirstValue(JwtRegisteredClaimNames.UniqueName)
            ?? principal.FindFirstValue(ClaimTypes.Name)
            ?? "unknown";
    }
}
