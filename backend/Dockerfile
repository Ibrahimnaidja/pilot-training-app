FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY MathQuiz.Api/*.csproj ./MathQuiz.Api/
RUN dotnet restore ./MathQuiz.Api
COPY MathQuiz.Api/. ./MathQuiz.Api/
RUN dotnet publish ./MathQuiz.Api -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app .
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "MathQuiz.Api.dll"]
