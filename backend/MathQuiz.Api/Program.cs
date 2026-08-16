using System.Text;
using MathQuiz.Api.Data;
using MathQuiz.Api.Endpoints;
using MathQuiz.Api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter());
});

// --- Database ---
// Connection string comes from (in priority order): DATABASE_URL env var
// (Render/Neon/Supabase style), then appsettings "ConnectionStrings:Default".
var rawConnectionString = Environment.GetEnvironmentVariable("DATABASE_URL")
    ?? builder.Configuration.GetConnectionString("Default")
    ?? throw new InvalidOperationException(
        "No database connection string found. Set DATABASE_URL or ConnectionStrings:Default.");

var connectionString = NormalizeConnectionString(rawConnectionString);

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

// Neon/Supabase/Render typically hand out "postgres://user:pass@host/db"
// style URIs, but Npgsql wants "Host=...;Username=...;Password=...".
// This converts the former to the latter; if it's already key-value style,
// it's returned unchanged.
static string NormalizeConnectionString(string value)
{
    if (!value.StartsWith("postgres://") && !value.StartsWith("postgresql://"))
        return value;

    var uri = new Uri(value);
    var userInfo = uri.UserInfo.Split(':', 2);
    var database = uri.AbsolutePath.TrimStart('/');
    var query = System.Web.HttpUtility.ParseQueryString(uri.Query);
    var sslMode = query["sslmode"] ?? "Require";

    return new Npgsql.NpgsqlConnectionStringBuilder
    {
        Host = uri.Host,
        Port = uri.Port > 0 ? uri.Port : 5432,
        Username = Uri.UnescapeDataString(userInfo[0]),
        Password = userInfo.Length > 1 ? Uri.UnescapeDataString(userInfo[1]) : "",
        Database = database,
        SslMode = Enum.TryParse<Npgsql.SslMode>(sslMode, true, out var mode) ? mode : Npgsql.SslMode.Require
    }.ConnectionString;
}

// --- Auth ---
var jwtSecret = Environment.GetEnvironmentVariable("JWT_SECRET")
    ?? builder.Configuration["Jwt:Secret"]
    ?? throw new InvalidOperationException("No JWT secret found. Set JWT_SECRET or Jwt:Secret.");
builder.Configuration["Jwt:Secret"] = jwtSecret;

builder.Services.AddSingleton<TokenService>();

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = false,
        ValidateAudience = false,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret))
    };
});
builder.Services.AddAuthorization();

// --- CORS ---
// Wide open for easy setup during development. Tighten this to your deployed
// frontend's exact origin before making this public.
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
    });
});

var app = builder.Build();

// Create the schema on startup if it doesn't exist yet. Fine for a personal
// project; switch to EF Core migrations if the schema needs to evolve
// without losing data later.
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await db.Database.EnsureCreatedAsync();
}

app.UseCors();
app.UseAuthentication();
app.UseAuthorization();

app.MapAuthEndpoints();
app.MapProblemEndpoints();
app.MapAttemptEndpoints();
app.MapStatsEndpoints();
app.MapLogicEndpoints();

app.MapGet("/", () => Results.Ok(new { status = "ok" }));

app.Run();
